# Copyright (c) 2026 Bryan C. Everly
# SPDX-License-Identifier: BSD-2-Clause
#
# restate's Homebrew formula. The release workflow writes restate.rb from this,
# with the version and the SHA-256 of the release's tarball, builds, tests and
# removes it on macOS, then pushes it to the bceverly/homebrew-tap tap:
#
#   brew install bceverly/tap/restate
class Restate < Formula
  desc "Record what makes a machine different from a fresh install"
  homepage "https://github.com/bceverly/restate"
  url "https://github.com/bceverly/restate/releases/download/v2.2.0.12/restate-2.2.0.12.tar.gz"
  sha256 "7068aecd73fd196becde1806f13735c6e8dab3b1baf7bd871434886372169649"
  license "BSD-2-Clause"

  def install
    system "make", "build", "VERSION=#{version}"
    system "make", "install-tree", "DESTDIR=", "prefix=#{prefix}", "sysconfdir=#{etc}",
           "VERSION=#{version}"
  end

  def caveats
    <<~EOS
      restate reads every file only as root: run it with sudo, and give the
      program that runs it (Terminal, or your shell's) Full Disk Access in
      System Settings > Privacy & Security, or what macOS protects is left out.

      As root, restate runs only programs and hooks that root owns and no one
      else may write, and Homebrew's are yours: its hooks in
      #{opt_libexec}/restate/hooks are not run, and an image's signature is
      checked only with a gpgv that is root's.
    EOS
  end

  test do
    assert_match "restate #{version}", shell_output("#{sbin}/restate --version")
    (testpath/"tree/etc").mkpath
    (testpath/"tree/etc/motd").write "hello\n"
    system sbin/"restate", "capture", "-N", "-q", "-r", testpath/"tree", "-o", testpath/"tree.tar"
    system sbin/"restate", "verify", "-N", "--root", testpath/"tree", testpath/"tree.tar"
  end
end
