class Elektra < Formula
  desc "Framework to access config settings in a global key database"
  homepage "https://libelektra.org/"
  url "https://www.libelektra.org/ftp/elektra/releases/elektra-0.9.4.tar.gz"
  sha256 "e1f11f063ab262ce056238ca17aa60442a450a0bb6c5f57a9959df0365576bc6"
  license "BSD-3-Clause"
  head "https://github.com/ElektraInitiative/libelektra.git"

  livecheck do
    url "https://www.libelektra.org/ftp/elektra/releases/"
    regex(/href=.*?elektra[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 big_sur:     "262acb6c0f4ecbfb8622f06d7e9f754a076991f2fef9cde53fc76fb8c0f30518"
    sha256 catalina:    "686d067559aa7e9f57b419a92c703d382abdf75b413b6d67854dec5ebf15873c"
    sha256 mojave:      "25e5bc4305fcde829a674d3734b9b18204d64acaf47027b322919703d9065b1f"
    sha256 high_sierra: "218f8e1b129c4796301062e43a842b2d39f7996c204f69d9f15857304a8230d0"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DBINDINGS=cpp", "-DTOOLS=kdb;",
                            "-DPLUGINS=NODEP", *std_cmake_args
      system "make", "install"
    end

    # Avoid references to the Homebrew shims directory
    inreplace Dir[prefix/"share/elektra/test_data/gen/gen/highlevel/*.check.sh"],
              HOMEBREW_SHIMS_PATH/"mac/super/", ""

    bash_completion.install "scripts/completion/kdb-bash-completion" => "kdb"
    fish_completion.install "scripts/completion/kdb.fish"
    zsh_completion.install "scripts/completion/kdb_zsh_completion" => "_kdb"
  end

  test do
    output = shell_output("#{bin}/kdb get system/elektra/version/infos/licence")
    assert_match "BSD", output
    shell_output("#{bin}/kdb plugin-list").split.each do |plugin|
      system "#{bin}/kdb", "plugin-check", plugin
    end
  end
end
