class Ember < Formula
  desc "GPU-accelerated campfire terminal emulator"
  homepage "https://emberterm.com"
  url "https://github.com/kingb/ember/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "8951b46b62a7a19852cece3fefd0e91407d353cbdef45db0ca8eec2dcf80af49"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/kingb/ember/releases/download/v0.6.2"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "23e738c97a362f8bbcabc9da984108e0b5f5b92c0dbe51ef9a3222531e5952a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "542b2ce876ec7aaa9610214635fbe502a18f2a118acf49745af148c3ebfc59b9"
  end

  # Intended for Linux (macOS installs the notarized app bundle via the cask
  # instead), but not hard-restricted: there's no real `depends_on` gate for
  # "Linux only" in Homebrew, and this builds fine cross-platform anyway.
  depends_on "rust" => :build

  # NOTE: on Ubuntu 22.04 install from the BOTTLE (the default). Building
  # from source through Homebrew's rust links Homebrew's newer glibc, and the
  # resulting binary cannot load the system GPU drivers there. Bottles are
  # built natively on 22.04 (glibc 2.35 ceiling) and run on 22.04/24.04/26.04.
  # Build-time headers for winit/wgpu's Wayland/X11/GL bindings. Deliberately
  # NOT depending on Homebrew's own mesa/vulkan-loader/libxkbcommon: the
  # built binary has zero link-time dependency on any of them (winit/wgpu
  # dlopen X11/Wayland/Vulkan/EGL at runtime, confirmed via ldd showing only
  # libc/libm/libgcc), so the system's real GPU driver stack is what actually
  # gets loaded regardless of what's on the build machine.
  on_linux do
    depends_on "pkg-config" => :build
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/ember-app")

    # Linux desktop integration (GNOME/KDE app grid + docks). Shipped under the
    # Homebrew prefix; GNOME does not scan it, so `caveats` prints a no-sudo
    # user-local copy one-liner that rewrites Exec= to the absolute brew path.
    # (Bottles carry these too — see scripts/release/bottle-build.sh.)
    return unless OS.linux?

    (share/"applications").install "extra/linux/ember-term.desktop"
    (share/"icons").install "extra/linux/icons/hicolor"
  end

  def caveats
    return unless OS.linux?

    <<~EOS
      To add Ember to your desktop environment (GNOME app grid, KDE launcher,
      docks) without sudo, copy the launcher into your user data dir with an
      absolute Exec path (GNOME does not scan the Homebrew prefix):

        mkdir -p ~/.local/share/applications ~/.local/share/icons
        sed 's|^Exec=ember-term$|Exec=#{opt_bin}/ember-term|; s|^TryExec=ember-term$|TryExec=#{opt_bin}/ember-term|' \\
          #{opt_prefix}/share/applications/ember-term.desktop > ~/.local/share/applications/ember-term.desktop
        cp -r #{opt_prefix}/share/icons/hicolor ~/.local/share/icons/
        update-desktop-database ~/.local/share/applications 2>/dev/null || true

      Ember then appears in the app grid; its windows group under the icon
      (WM_CLASS/app_id = ember-term).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ember-term --version")
  end
end
