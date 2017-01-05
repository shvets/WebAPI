class Project < Thor
  desc "tests_list", "lists tests"
  def tests_list
    system "swift test -l"
  end

  desc "test", "run test(s)"
  def test(*params)
    puts params
    system "swift test -s " + params.join(' ')
  end

  desc "generate", "generate project file"
  def generate
    system "swift package generate-xcodeproj"
  end

  desc "build", "builds application"
  def build(*params)
    puts params
    system "swift build"
  end

  desc "tag", "tag project"
  def tag
    system "git tag 1.0.0"
    system "gut push --tags"
  end

  desc "clean", "cleans project"
  def clean
    system "rm -rf .build"
  end
end