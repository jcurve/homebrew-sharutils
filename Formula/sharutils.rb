# based on coreutils.rb
class Sharutils < Formula
  desc "GNU Shell Archive Utilities utilities"
  homepage "https://www.gnu.org/software/sharutils/"
  url "http://ftp.gnu.org/gnu/sharutils/sharutils-4.15.2.tar.xz"
  sha256 "2b05cff7de5d7b646dc1669bc36c35fdac02ac6ae4b6c19cb3340d87ec553a9a"
  revision 1

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "gettext" => :build
  depends_on "texinfo" => :build
  depends_on "xz" => :build
  depends_on "wget" => :build

  def install
    if MacOS.version == :el_capitan
      # Work around unremovable, nested dirs bug that affects lots of
      # GNU projects. See:
      # https://github.com/Homebrew/homebrew/issues/45273
      # https://github.com/Homebrew/homebrew/issues/44993
      # This is thought to be an el_capitan bug:
      # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
      ENV["gl_cv_func_getcwd_abort_bug"] = "no"
    end

    args = %W[
      --prefix=#{prefix}
      --program-prefix=g
    ]

    system "./configure", *args
    system "make", "install"

    # Symlink all commands into libexec/gnubin without the 'g' prefix
    sharutils_filenames(bin).each do |cmd|
      (libexec/"gnubin").install_symlink bin/"g#{cmd}" => cmd
    end
    # Symlink all man(1) pages into libexec/gnuman without the 'g' prefix
    sharutils_filenames(man1).each do |cmd|
      (libexec/"gnuman"/"man1").install_symlink man1/"g#{cmd}" => cmd
    end

    # Symlink non-conflicting binaries
    bin.install_symlink "grealpath" => "realpath"
    man1.install_symlink "grealpath.1" => "realpath.1"
  end

  def caveats; <<~EOS
    All commands have been installed with the prefix 'g'.

    If you really need to use these commands with their normal names, you
    can add a "gnubin" directory to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"

    Additionally, you can access their man pages with normal names if you add
    the "gnuman" directory to your MANPATH from your bashrc as well:

        MANPATH="#{opt_libexec}/gnuman:$MANPATH"

    EOS
  end

  def sharutils_filenames(dir)
    filenames = []
    dir.find do |path|
      next if path.directory? || path.basename.to_s == ".DS_Store"
      filenames << path.basename.to_s.sub(/^g/, "")
    end
    filenames.sort
  end
end