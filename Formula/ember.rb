class Ember < Formula
  desc "GPU-accelerated campfire terminal emulator"
  homepage "https://emberterm.com"
  url "https://github.com/kingb/ember/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "14d1c8a5e3eec8f00ab40fe565a5ad8836656656db84d9bde8c03300e94c9868"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/kingb/ember/releases/download/v0.2.1"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "3ad71c4df712f995a3f2efd3853c0bd277698932c3a5d91dd6ae137d71cf56f1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "08a79cf81037c62e502b8c74631d29003828d7746b1edd1c5644271730e7c376"
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
