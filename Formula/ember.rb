class Ember < Formula
  desc "GPU-accelerated campfire terminal emulator"
  homepage "https://emberterm.com"
  url "https://github.com/kingb/ember/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "2248618815be871ffb34b6106012fed732a76b48b84f68628b851b107f0e2854"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/kingb/ember/releases/download/v0.2.0"
    rebuild 1
    sha256 cellar: :any, arm64_linux:  "4d1d3070ded63016645eddc993f4e84be13afa194d829fb63bc2cf9da674a270"
    sha256 cellar: :any, x86_64_linux: "36af09562f774c903ba1012eb7de8fdc30840c5c4c60df0b06cba077e4fbf459"
  end

  # Intended for Linux (macOS installs the notarized app bundle via the cask
  # instead), but not hard-restricted: there's no real `depends_on` gate for
  # "Linux only" in Homebrew, and this builds fine cross-platform anyway.
  depends_on "rust" => :build

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
