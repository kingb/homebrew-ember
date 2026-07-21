class Ember < Formula
  desc "GPU-accelerated campfire terminal emulator"
  homepage "https://emberterm.com"
  url "https://github.com/kingb/ember/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "9faf7ff1538946f4bf992df75191a500a9b655ca3098eb73b52a18c8cc509660"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/kingb/ember/releases/download/v0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "781cfa5e84e1901a5036f2ee32a6c3168bd4f4ea8782c3e0652328700df70b50"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "fb4c88488915e3be08a38fccc130a2d336862a03dd2e0855bc5febdeed58ed90"
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
