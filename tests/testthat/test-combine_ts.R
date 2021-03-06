context('combine_ts') 

test_that("combine_ts works", {
  xy <- download_ts(c('suntime_calcLon', 'doobs_nwis', 'wtr_nwis', 'baro_nldas'), 'nwis_01467087', on_local_exists="replace")
  dim(base <- read_ts(xy[1]))
  dim(same <- read_ts(xy[2]))
  dim(more <- read_ts(xy[3]))
  dim(offset <- read_ts(xy[4])[1:1234,])
  library(dplyr); library(unitted)
  datevec <- seq(Sys.time(), Sys.time()+as.difftime(1, units='hours'), by=as.difftime(1, units='mins'))
  offline <- unitted::u(data.frame(DateTime=datevec, suntime=datevec-as.difftime(5.4, units='hours')))
  offpar <- unitted::u(data.frame(DateTime=datevec, par=unitted::u(seq(101,161),'umol m^-2 s^-1')))
  const <- unitted::u(data.frame(DateTime=NA, baro=unitted::u(75000,'Pa')))
  
  # combine ts with const
  ocf <- combine_ts(offline, const, method='full_join')
  expect_equal(dim(ocf), c(dim(offline)[1], 3))
  oci <- combine_ts(offline, const, method='inner_join')
  expect_equal(dim(oci), c(dim(offline)[1], 3))
  ocl <- combine_ts(offline, const, method='left_join')
  expect_equal(dim(ocl), c(dim(offline)[1], 3))
  oca <- combine_ts(offline, const, method='approx')
  expect_equal(dim(oca), c(dim(offline)[1], 3))
  expect_equal(ocf, oci)
  expect_equal(ocf, ocl)
  expect_equal(ocf, oca)
  expect_error(combine_ts(const, offline, method='approx'))
  
  # two same-dated tses
  oof <- combine_ts(offline, offpar, method='full_join')
  expect_equal(dim(oof), c(dim(offline)[1], 3))
  bsf <- combine_ts(base, same, method='full_join')
  expect_equal(dim(bsf), c(dim(base)[1], 3))
  bsi <- combine_ts(base, same, method='inner_join')
  expect_equal(dim(bsi), c(dim(base)[1], 3))
  bsl <- combine_ts(base, same, method='left_join')
  expect_equal(dim(bsl), c(dim(base)[1], 3))
  bsa <- combine_ts(base, same, method='approx')
  expect_equal(dim(bsa), c(dim(base)[1], 3))
  
  # 2nd ts has more points. base=suntime, more=wtr
  bmf <- combine_ts(base, more, method='full_join')
  expect_equal(dim(bmf)[2], 3)
  expect_more_than(dim(bmf)[1], dim(base)[1])
  expect_more_than(dim(bmf)[1], dim(more)[1])
  mbf <- combine_ts(more, base, method='full_join')
  expect_equal(dim(mbf), dim(bmf))
  bmi <- combine_ts(base, more, method='inner_join')
  expect_less_than(dim(bmi)[1], dim(base)[1])
  bml <- combine_ts(base, more, method='left_join')
  expect_equal(dim(bml), c(dim(base)[1], 3))
  # if we ever expected to merge suntime as a secondary variable, we'd probably
  # be fine extrapolating a long way. but in general i expect suntime will be
  # the leftmost in a call to combine_ts anyway.
  bma <- combine_ts(base, more, method='approx', approx_tol=as.difftime(3, units="hours"))
  expect_equal(dim(bma), c(dim(base)[1], 3))
  mba <- combine_ts(more, base, method='approx', approx_tol=as.difftime(3, units="hours"))
  expect_equal(dim(mba), c(dim(more)[1], 3))
  expect_equal(mba$suntime[mba$DateTime=="2015-03-09 23:00:00 UTC"], base$suntime[base$DateTime=="2015-03-09 23:00:00 UTC"])
  # dates should be added to mba only when they're close to pre-existing dates
  extras_from_more <- as.POSIXct(setdiff(more$DateTime, base$DateTime), origin="1970-01-01 00:00:00")
  added_dates <- mba[mba$DateTime %in% extras_from_more, "suntime"]
  expect_false(is.na(added_dates[2]))
  expect_true(is.na(added_dates[50]))
  expect_false(is.na(added_dates[75]))

  # two tses with entirely non-overlapping dates
  bof <- combine_ts(base, offset, method='full_join')
  expect_equal(dim(bof), c(dim(base)[1]+dim(offset)[1], 3))
  boi <- combine_ts(base, offset, method='inner_join')
  expect_equal(dim(boi), c(0, 3))
  bol <- combine_ts(base, offset, method='left_join')
  expect_equal(dim(bol), c(dim(base)[1], 3))
  expect_true(all(is.na(bol$baro)))
  boa <- combine_ts(base, offset, method='approx', approx_tol=as.difftime(3, units="hours"))
  expect_equal(dim(boa), c(dim(base)[1], 3))
  expect_true(all(is.na(boa$baro)))
  
})