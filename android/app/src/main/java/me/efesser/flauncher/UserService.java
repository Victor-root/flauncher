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

import java.io.BufferedReader;
import java.io.InputStreamReader;

// Runs inside a separate process started by Shizuku with shell (or root) privileges. Commands passed
// from the application therefore execute with those privileges.
public class UserService extends IUserService.Stub {

    public UserService() { }

    @Override
    public void destroy() {
        System.exit(0);
    }

    @Override
    public void exit() {
        destroy();
    }

    @Override
    public String execute(String[] command) {
        StringBuilder output = new StringBuilder();

        try {
            Process process = Runtime.getRuntime().exec(command);

            try (BufferedReader stdout = new BufferedReader(new InputStreamReader(process.getInputStream()));
                 BufferedReader stderr = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
                String line;
                while ((line = stdout.readLine()) != null) {
                    output.append(line).append('\n');
                }
                while ((line = stderr.readLine()) != null) {
                    output.append(line).append('\n');
                }
            }

            int exitCode = process.waitFor();
            output.append("exit:").append(exitCode);
        } catch (Exception exception) {
            output.append("error:").append(exception.getMessage());
        }

        return output.toString();
    }
}
