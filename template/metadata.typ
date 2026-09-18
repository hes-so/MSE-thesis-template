#import "@preview/hes-so-package:0.0.6": *
#import "@preview/mse-thesis-template:0.0.2": *

//-------------------------------------
// Document options
//
#let option = (
  type : sys.inputs.at("type", default:"draft"),    // [draft|final]
  lang : sys.inputs.at("lang", default:"en"),       // [en|fr|de]
  template  : "master",   // [pa|pi|master|bachelor|midterm]
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.3.2":*
#let project-logo= dragon-curve(
  12,
  step-size: 1.6,
  stroke: stroke(
    paint: gradient.radial(..color.map.rocket),
    thickness: 0.5pt, join: "round"
  )
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : "Thesis Template",
  subtitle : "Longer Subtitle",
  author: ( // In case of multi author, add one or more author with at least the name field.
    (
      gender      : "masculin",  // ["masculin"|"feminin"|"inclusive"]
      name        : "Firstname Lastname",
      email       : "firstname.lastname@master.hes-so.ch",
      degree      : "Master",
      affiliation : "HES-SO",
      place       : "Lausanne",
      url         : "https://hes-so.ch",
      signature   : image("/resources/img/signature.svg", width:3cm),
    ),
  ),
  keywords : ("HES-SO", "MSE", "Computer Science", "Thesis", "Template"),
  version  : "v0.1.0",
)

// Thesis Data Page
#let thesis-data-page = none // [none|content]
// Summary Page
#let summary-page = (
  logo: project-logo,
  //one sentence with max. 240 characters, with spaces.
  objective: [
    The objective of this thesis is to analyze and improve the performance of a predictive maintenance system in industrial IoT environments by implementing advanced data processing algorithms and evaluating their effectiveness through case studies.
  ],
  //summary max. 1200 characters, with spaces.
  content: [
   This thesis focuses on the optimization of predictive maintenance systems within industrial IoT environments. Predictive maintenance is a key aspect of modern manufacturing, enabling the anticipation of equipment failures and reducing downtime. The research begins by outlining the theoretical foundations of predictive maintenance, including sensor data acquisition, processing, and analysis. The study then introduces advanced data processing algorithms, such as machine learning techniques, to enhance prediction accuracy and reliability. A case study approach is employed, using real-world industrial data to evaluate the system’s performance. The results demonstrate significant improvements in fault detection rates and decision-making efficiency. The thesis concludes by discussing the implications for industry and providing recommendations for future development. This work aims to contribute to the advancement of smart maintenance systems, supporting industry 4.0 transformation efforts.
  ],
  address: [HES-SO Master • Av. de Provence 6 • 1007 Lausanne \ + 41 58 900 00 00 • #link("mailto"+"mse@hes-so.ch")[mse\@hes-so.ch] • #link("https://www.hes-so.ch/en/master/hes-so-master/programmes/engineering-mse")[www.hes-so.ch]]
)

// Display Options for additional pages
#let display = (
  report-info: true,  // [true|false] display report info with declaration of honor
  thesis-data: false,  // [true|false] display thesis data page
  summary: true,      // [true|false] display summary page
)

#let professor = (
  (
    affiliation: "HEI-Vs",
    name: "Prof. Silvan Zahno",
    email: "silvan.zahno@hevs.ch",
  ),
)
#let expert = (
  (
    affiliation: "Company",
    name: "Expert Name",
    email: "expert@domain.ch",
  ),
)
#let school= (
  name: none,
  orientation: none,
  specialisation: none,
)
#if option.lang == "de" {
  school.name = "Fachhochschule Westschweiz, HES-SO Master in Ingenieurwissenschaften"
  school.shortname = "HES-SO MSE"
  school.orientation = "Computer Science"
  school.specialisation = "Embedded"
} else if option.lang == "fr" {
  school.name = "Haute école spécialisée de Suisse occidentale, HES-SO Master en Science de l'Ingénierie"
  school.shortname = "HES-SO MSE"
  school.orientation = "Computer Science"
  school.specialisation = "Embarqué"
} else {
  school.name = "University of Applied Sciences Western Switzerland, HES-SO Master of Science in Engineering"
  school.shortname = "HES-SO MSE"
  school.orientation = "Computer Science"
  school.specialisation = "Embedded"
}

#let is-confidential = false // [true|false] display confidential notice on title page

#let date = (
  submission: datetime(year: 2026, month: 8, day: 14),
  mid-term-submission: datetime(year: 2026, month: 5, day: 1),
  today: datetime.today(),
)

#let logos = (
  main: project-logo,
  topleft: image(logos.mse, width: 7.5cm),
  topright: image(logos.hesso-full, width: 4cm),
  bottomleft: none,
  bottomright: image(logos.swissuniversities, width: 5cm),
)

//-------------------------------------
// Settings
//
#let tableof = (
  toc: true,
  tof: false,
  tot: false,
  tol: false,
  toe: false,
  maxdepth: 3,
)

#let gloss    = true
#let appendix = false
#let bib = (
  display : true,
  path  : "/tail/bibliography.bib",
  style : "ieee", //"apa", "chicago-author-date", "chicago-notes", "mla"
)

#let fonts = (
  text: "Libertinus Serif",
  mono: "DejaVu Sans Mono",
  math: "New Computer Modern Math",
)
