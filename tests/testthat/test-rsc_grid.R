get_attribs <- function(widget) widget$x$tag$attribs

content_sample <- data.frame(
  guid = c(
    "991f16c5-dc7e-4403-89d0-c54d10968460",
    "4b5345cc-8dc5-46fa-80ed-1a389d80e21b",
    "100881c9-0162-4f3f-b973-6870085d48ff"
  ),
  url = c(
    "https://connect.tester.net/content/991f16c5-dc7e-4403-89d0-c54d10968460/",
    "https://connect.tester.net/content/4b5345cc-8dc5-46fa-80ed-1a389d80e21b/",
    "https://connect.tester.net/content/100881c9-0162-4f3f-b973-6870085d48ff/"
  ),
  title = c("One", "Two", "Three"),
  owner_username = c("bob", "jerry", "adam"),
  app_mode = c("api", "rmd-static", "shiny"),
  tags = c("blue", "green", "pale yellow"),
  updated_time = c(
    "Sat Oct 03 2020",
    "Sun Jan 24 2021",
    "Fri Oct 30 2020"
  )
)

test_that("rsc_grid handles invalid/missing args", {
  # missing content param
  expect_error(rsc_grid())

  # not a data frame or crosstalk object
  expect_error(rsc_grid("marshmallow"))

  # requires "guid", "url", "title", "app_mode", "owner_username"
  content <- data.frame(id = c("1", "2", "3"))
  expect_error(rsc_grid(content))

  guid <- c(
    "991f16c5-dc7e-4403-89d0-c54d10968460",
    "4b5345cc-8dc5-46fa-80ed-1a389d80e21b",
    "100881c9-0162-4f3f-b973-6870085d48ff"
  )
  content <- cbind(content, guid)
  expect_error(rsc_grid(content))

  title <- c("One", "Two", "Three")
  content <- cbind(content, title)
  expect_error(rsc_grid(content))

  url <- c(
    "https://connect.tester.net/content/991f16c5-dc7e-4403-89d0-c54d10968460/",
    "https://connect.tester.net/content/4b5345cc-8dc5-46fa-80ed-1a389d80e21b/",
    "https://connect.tester.net/content/100881c9-0162-4f3f-b973-6870085d48ff/"
  )
  content <- cbind(content, url)
  expect_error(rsc_grid(content))

  app_mode <- c("api", "rmd-static", "shiny")
  content <- cbind(content, app_mode)
  expect_error(rsc_grid(content))

  owner_username <- c("bob", "jerry", "adam")
  content <- cbind(content, owner_username)

  # warnings for missing "updated_time"
  expect_warning(rsc_grid(content))

  updated_time <- c(
    "Sat Oct 03 2020",
    "Sun Jan 24 2021",
    "Fri Oct 30 2020"
  )
  content <- cbind(content, updated_time)
  expect_warning(
    rsc_grid(content),
    NA
  )
})

test_that("should warn on large content", {
  over_max_size <- 501
  content <- data.frame(
    guid = rep("100881c9-0162-4f3f-b973-6870085d48ff", times = over_max_size),
    title = rep("Test", times = over_max_size),
    url = rep(
      "https://example.com/content/991f16c5-dc7e-4403-89d0-c54d10968460/",
      times = over_max_size
    ),
    app_mode = rep("api", times = over_max_size),
    owner_username = rep("bob", times = over_max_size),
    description = rep("Lorem ipsum", times = over_max_size),
    updated_time = rep("Sat Oct 03 2020", times = over_max_size)
  )

  expect_warning(
    rsc_grid(content),
    "exceeds maximum"
  )
})

test_that("rsc_grid container", {
  widget <- rsc_grid(content_sample)
  attrs <- get_attribs(widget)

  expect_equal(attrs$data$guid, content_sample$guid)
  expect_equal(attrs$data$url, content_sample$url)
  expect_equal(attrs$data$title, content_sample$title)
  expect_equal(length(attrs$crosstalkKey), 3)
  expect_true(length(attrs$crosstalkGroup) > 0)
})

test_that("rsc_grid supports crosstalk", {
  sh <- crosstalk::SharedData$new(
    content_sample,
    key = ~guid,
    group = "gridzzz"
  )

  widget <- rsc_grid(sh)
  attrs <- get_attribs(widget)

  expect_true("991f16c5-dc7e-4403-89d0-c54d10968460" %in% attrs$crosstalkKey)
  expect_true("4b5345cc-8dc5-46fa-80ed-1a389d80e21b" %in% attrs$crosstalkKey)
  expect_true("100881c9-0162-4f3f-b973-6870085d48ff" %in% attrs$crosstalkKey)
  expect_equal(attrs$crosstalkGroup, "gridzzz")
})

test_that("rscgridOutput", {
  output <- rscgridOutput("mygridz")

  # HTML dependencies should be intact
  deps <- htmltools::htmlDependencies(output)
  expect_true(length(deps) > 0)

  # Output container should have data-reactable-output ID set
  expect_equal(output[[1]][[4]]$name, "div")
  expect_equal(output[[1]][[4]]$attribs$id, "mygridz")
  expect_equal(
    output[[1]][[4]]$attribs$class,
    "rsc_grid html-widget html-widget-output"
  )
})
