class Ember < Formula
  desc "GPU-accelerated campfire terminal emulator"
  homepage "https://emberterm.com"
  url "https://github.com/kingb/ember/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "6925c3e35a806d78cf37f1c096fb8de5d973bfe4ee36dc055db0e715c391e88b"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/kingb/ember/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "c5d44530b8e119c29a70a79bec62dab969f14861a00e0859bc5c501785231141"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bd623ac719696de0fc98a2fe0b03efb57cdc82f958f166d67a5313c2091dca6d"
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
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ember-term --version")
  end
end
