// IUserService.aidl
package me.efesser.flauncher;

interface IUserService {
    void destroy() = 16777114; // Destroy method defined by Shizuku server

    void exit() = 1;

    String execute(in String[] command) = 2;
}
