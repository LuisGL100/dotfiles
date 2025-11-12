# dotfiles

My personal dotfiles and macOS setup scripts.

## Usage

### Setting up a new Mac

This script's main purpose is to **quickly and automatically configure a brand-new Mac**.

While it performs basic checks (e.g., whether something is already installed), it's intended for use on a **clean system**. It assumes the user:

* Has `sudo` access
* Is not behind a proxy
* Is not restricted by MDM or corporate policies

> ⚠️ It likely **won’t work on corporate-managed machines**.

Once you’re past the initial macOS setup screens:

1. Open **Safari** and go to [`github.com/LuisGL100/dotfiles`](https://github.com/LuisGL100/dotfiles)

2. Open **Terminal** and run one of the following commands:

   **Option A: Run script immediately**

   ```bash
   curl -fsSL "https://raw.githubusercontent.com/LuisGL100/dotfiles/refs/heads/main/install.sh" | source /dev/stdin 0
   ```

   **Option B: Download script first**

   ```bash
   curl -fsSL "https://raw.githubusercontent.com/LuisGL100/dotfiles/refs/heads/main/install.sh" -o mac_setup.sh
   ```

   Then, when ready:

   ```bash
   caffeinate zsh mac_setup.sh
   ```

3. Enter your password when prompted (for `sudo`). This is required only once, to install [Homebrew](https://brew.sh/).

4. When the script completes, it will automatically quit the Terminal.

5. Re-launch the Terminal, ~~and follow the prompts to finish setting up **Powerlevel10k (P10k)**~~ (this is now automated 🎉).

6. Done 🎉

---

### Development & Testing

Since this script is designed for new machines, testing changes can be tricky. Thankfully, the [Virtualization Framework](https://developer.apple.com/documentation/virtualization) (Apple Silicon only) makes it possible to run macOS in a virtual machine ([1](#notes)).

Apple provides a [fully working sample project](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon) for this. You **don’t need to modify the code**, but understanding the process and the generated artifacts is important ([2](#notes)).

For a deeper explanation, watch [this WWDC video](https://www.youtube.com/watch?v=mg5GxH81X5M&t=840s).

#### Steps

1. Clone and open the sample app.
   Run any of the `InstallationTool-X` schemes and wait patiently—it can take a while.

   This will:

   * **Download** the macOS restore image (`*.ipsw`, \~20GB)
   * **Install** that image into a new VM, producing a `VM.bundle`

2. Once installation is complete, run any of the `macOSVirtualMachineSampleApp-X` schemes. This boots the VM and shows macOS setup screens.

3. Complete the setup process in the VM.
   Then from the app’s menu bar, select:
   `macOSVirtualMachineSampleApp` → `Save and quit macOSVirtualMachineSampleApp`

4. Create a backup of this "pristine" state so you can quickly and easily reset the VM later:

   ```bash
   cp -r ~/VM.bundle ~/VMPristine.bundle
   ```

   * `VM.bundle`: your **working VM**
   * `VMPristine.bundle`: your **clean snapshot**

5. Now you can modify and run your setup script inside the VM.

6. To reset the VM back to the "pristine" state:

   ```bash
   rm -Rf ~/VM.bundle
   cp -r ~/VMPristine.bundle ~/VM.bundle
   ```

7. If anything happens to the "pristine" copy, you can always create another one by re-running any of the `InstallationTool-X` schemes.
   If you still happen to have the `*.ipsw` downloaded in Step 1, add its path to the Scheme's "Arguments passed on launch" in the "Run" step, to avoid downloading it again.
   The default path should be `$(HOME)/RestoreImage.ipsw`, unless you changed it.

---

### Notes

1. There are also [other testing options](https://github.com/geerlingguy/mac-dev-playbook?tab=readme-ov-file#testing-the-playbook) available.
2. Requires an [Apple Developer account](https://developer.apple.com/register/).
