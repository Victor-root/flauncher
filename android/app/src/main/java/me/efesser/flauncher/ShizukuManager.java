/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package me.efesser.flauncher;

import android.content.ComponentName;
import android.content.Context;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import rikka.shizuku.Shizuku;

// Bridges the application to Shizuku. Privileged actions (disabling the stock launcher, force stopping
// an application) are executed inside a UserService that Shizuku runs with shell privileges.
public class ShizukuManager {

    public interface ResultCallback {
        void onResult(String output);
    }

    private final Context _context;
    private final Handler _mainHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService _executor = Executors.newSingleThreadExecutor();

    private IUserService _userService;

    public ShizukuManager(Context context) {
        _context = context.getApplicationContext();
    }

    public boolean isAvailable() {
        try {
            return Shizuku.pingBinder();
        } catch (Throwable ignored) {
            return false;
        }
    }

    public boolean hasPermission() {
        try {
            return isAvailable()
                    && !Shizuku.isPreV11()
                    && Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED;
        } catch (Throwable ignored) {
            return false;
        }
    }

    public void requestPermission(int requestCode) {
        try {
            if (isAvailable() && !Shizuku.isPreV11()) {
                Shizuku.requestPermission(requestCode);
            }
        } catch (Throwable ignored) { }
    }

    public void execute(String[] command, ResultCallback callback) {
        if (!hasPermission()) {
            callback.onResult("error:no_permission");
            return;
        }

        if (_userService != null) {
            _runCommand(command, callback);
            return;
        }

        Shizuku.UserServiceArgs args = new Shizuku.UserServiceArgs(new ComponentName(_context, UserService.class))
                .daemon(false)
                .processNameSuffix("shizuku")
                .debuggable(false)
                .version(1);

        ServiceConnection connection = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder binder) {
                if (binder != null && binder.pingBinder()) {
                    _userService = IUserService.Stub.asInterface(binder);
                    _runCommand(command, callback);
                } else {
                    _postResult(callback, "error:bind_failed");
                }
            }

            @Override
            public void onServiceDisconnected(ComponentName name) {
                _userService = null;
            }
        };

        try {
            Shizuku.bindUserService(args, connection);
        } catch (Throwable throwable) {
            _postResult(callback, "error:" + throwable.getMessage());
        }
    }

    private void _runCommand(String[] command, ResultCallback callback) {
        _executor.execute(() -> {
            String output;
            try {
                output = _userService.execute(command);
            } catch (Throwable throwable) {
                output = "error:" + throwable.getMessage();
            }
            _postResult(callback, output);
        });
    }

    private void _postResult(ResultCallback callback, String output) {
        _mainHandler.post(() -> callback.onResult(output));
    }
}
