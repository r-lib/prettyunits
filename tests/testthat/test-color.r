context("Pretty color")

test_that("pretty_color works", {
  expect_equal(
    pretty_color("black"),
    structure("black", alt=c("black", "gray0", "grey0", "Black"))
  )
  expect_equal(
    pretty_color("#123456"),
    structure("black", alt=c("black", "gray0", "grey0", "Black"))
  )
  expect_equal(
    pretty_color("#123456", color_set="complete"),
    structure("Prussian Blue", alt=c("Prussian Blue"))
  )
  expect_equal(
    pretty_color(NA_character_),
    structure(NA_character_, alt=NA_character_)
  )
})
