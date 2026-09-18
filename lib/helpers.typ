#import "@preview/hes-so-package:0.0.6": *

#let _pkg-i18n = i18n
#let i18n(key, lang: "en", extra-i18n: (:)) = _pkg-i18n(
  key,
  lang: lang,
  extra-i18n: merge-dicts(
    json("i18n-thesis.json"),
    extra-i18n
  )
)

#let get-gendered-label(
  gender,
  key-base,
  lang: "en",
) = {
  if gender == "feminin" {
    i18n(key-base + "-f", lang: lang)
  } else if gender == "inclusive" {
    i18n(key-base + "-i", lang: lang)
  } else {
    i18n(key-base, lang: lang)
  }
}
