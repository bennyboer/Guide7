package de.be.thaw;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import com.joanzapata.iconify.Iconify;
import com.joanzapata.iconify.fonts.FontAwesomeModule;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;

import de.be.thaw.auth.Auth;
import de.be.thaw.auth.CertificateUtil;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.User;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.auth.exception.UserStoreException;
import de.be.thaw.exception.ExceptionHandler;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.connect.zpa.exception.ZPABadCredentialsException;
import de.be.thaw.util.ThawUtil;

public class LoginActivity extends AppCompatActivity {

	public static final String AUTO_LOGIN_EXTRA = "autoLogin";

	private EditText usernameField;
	private EditText passwordField;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));

		// Setup Iconify
		Iconify.with(new FontAwesomeModule());

		// Try to set up ZPA Certificate
		try {
			CertificateUtil.initCertificate(this);
		} catch (CertificateException | KeyStoreException | IOException | NoSuchAlgorithmException | KeyManagementException e) {
			e.printStackTrace();
		}

		Intent intent = getIntent();
		boolean doAutoLogin = intent.getBooleanExtra(AUTO_LOGIN_EXTRA, true);

		// Check for already existant user.
		User user = null;
		try {
			user = Auth.getInstance().getCurrentUser(this);
		} catch (NoUserStoredException e) {
			// There is no credential.
		}

		if (doAutoLogin && user != null) {
			goToMainActivity();
		}

		// Build GUI
		setContentView(R.layout.activity_login);

		// Initially get Views
		usernameField = (EditText) findViewById(R.id.username);
		passwordField = (EditText) findViewById(R.id.password);

		// Set username and password if user available.
		if (user != null) {
			usernameField.setText(user.getCredential().getUsername());
			passwordField.setText(user.getCredential().getPassword());
		}
	}

	public void onLogin(View view) {
		final String username = usernameField.getText().toString();
		final String password = passwordField.getText().toString();

		final User user = new User(null, null, new Credential(username, password));

		// Try Login
		new LoginTestTask(this, new Runnable() {

			@Override
			public void run() {
				// Save user.
				try {
					Auth.getInstance().setCurrentUser(LoginActivity.this, user);
				} catch (UserStoreException | NoUserStoredException e) {
					e.printStackTrace();
				}

				// Clear all previously cached data.
				ThawUtil.clearCaches(LoginActivity.this);

				goToMainActivity();
			}

		}).execute(user);
	}

	private void goToMainActivity() {
		Intent intent = new Intent(this, MainActivity.class);
		startActivity(intent);

		finish();
	}

	/**
	 * Test Login to ZPA.
	 */
	private class LoginTestTask extends AsyncTask<User, Integer, Boolean> {

		private ProgressDialog progress;
		private Activity activity;
		private Runnable callback;
		private Exception e;

		public LoginTestTask(Activity activity, Runnable callback) {
			this.activity = activity;
			this.callback = callback;
			this.progress = new ProgressDialog(activity);
			progress.setIndeterminate(true);
			progress.setMessage(activity.getResources().getString(R.string.loginMessage));
		}

		@Override
		protected Boolean doInBackground(User... users) {
			User user = users[0]; // Only one user obviously.

			try {
				ZPAConnection connection = new ZPAConnection(user, true);
			} catch (Exception e) {
				this.e = e; // Store Exception for later.
				return false;
			}

			return true;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			progress.show();
		}

		@Override
		protected void onPostExecute(Boolean aBoolean) {
			super.onPostExecute(aBoolean);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			if (!aBoolean) {
				if (e instanceof ZPABadCredentialsException) {
					new AlertDialog.Builder(activity).setMessage(getResources().getString(R.string.badLoginMessage)).show();
				} else {
					new AlertDialog.Builder(activity).setMessage(getResources().getString(R.string.loginErrorMessage)).show();
				}
			} else {
				callback.run();
			}
		}

		@Override
		protected void onCancelled(Boolean aBoolean) {
			super.onCancelled(aBoolean);

			if (progress.isShowing()) {
				progress.dismiss();
			}
		}

	}

}
