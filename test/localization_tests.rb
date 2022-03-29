require 'test/unit'
require_relative '../lib/minigl'
include MiniGL

class LocalizationTest < Test::Unit::TestCase
  def setup
    Res.prefix = File.expand_path(File.dirname(__FILE__)) + '/data'
    Localization.initialize
  end

  def test_languages
    assert_equal([:english, :portuguese], Localization.languages)
  end

  def test_language
    assert_equal(:english, Localization.language)
    Localization.language = :portuguese
    assert_equal(:portuguese, Localization.language)
    assert_raise { Localization.language = :invalid }
    assert_equal(:portuguese, Localization.language)
  end

  def test_strings
    assert_equal('Common string.', Localization.text(:str1))
    assert_equal('String with $ dollar sign.', Localization.text(:str2))
    assert_equal('something should be replaced.', Localization.text(:str3, 'something'))
    assert_equal('Should replace both 5 and true.', Localization.text(:str4, 5, true))
    assert_equal('String with \\ backslash.', Localization.text(:str5))
    assert_equal("String with\nline breaks.\n", Localization.text(:str6))
    assert_equal('<MISSING STRING>', Localization.text(:str7))

    Localization.language = :portuguese
    assert_equal('String comum.', Localization.text(:str1))
    assert_equal('String com $ cifrão.', Localization.text(:str2))
    assert_equal('algo deve ser substituído.', Localization.text(:str3, 'algo'))
    assert_equal('Deve substituir 5 e true.', Localization.text(:str4, 5, true))
    assert_equal('String com \\ barra invertida.', Localization.text(:str5))
    assert_equal("String com\nquebras de linha.\n", Localization.text(:str6))
    assert_equal('<MISSING STRING>', Localization.text(:str7))
  end
end
