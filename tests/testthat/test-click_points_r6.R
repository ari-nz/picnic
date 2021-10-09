test_that("expected_results", {


    cp = list(list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185),
              list(lat = -36.9219008721262, lng = 174.821319580078, .nonce = 0.891240011649733),
              list(lat = -36.8636907959613, lng = 174.829559326172, .nonce = 0.453579001691568))


    p = Points$new()

    testthat::expect_s3_class(p, c("demopoints", "R6"))




    p$add(cp[[1]])

    testthat::expect_equal(p$get_active(),

                           structure(
                               list(lat = -36.8900555751941,
                                    lng = 174.754028320313,
                                    active = TRUE,
                                    pointId = 1
                               ), row.names = c(NA, -1L),
                               class = c("tbl_df","tbl", "data.frame")
                           )
    )


    p$add(cp[[2]])
    p$remove(1)

    out = p$get_active()

    testthat::expect_equal(nrow(out), 1L)

})
