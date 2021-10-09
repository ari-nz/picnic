
pkgload::load_all()


cp = tibble::tribble(
 ~lat ,     ~lng ,   ~.nonce,
  -36.90049 ,174.7691, 0.9062808,
  -36.88731 ,174.6455, 0.8194645,
  -36.88951 ,174.8982, 0.1318054,
  -36.98720 ,174.7691, 0.3483685
)

test = osrm::osrmIsometric(c(cp[[1,2]],cp[[1,1]]), breaks = c(0,3,5,10)*1e3, osrm.profile='bike')
mapview::mapview(test)



route <- osrm::osrmRoute(src = c(cp[[1,2]],cp[[1,1]]), dst = c(cp[[2,2]],cp[[2,1]]), overview = "full", returnclass = "sf", osrm.profile='bike')
mapview::mapview(route)



library(mapboxapi)
library(mapdeck)
isochrones <- mb_isochrone(c(174.7691,-36.90049),
                           time = c(30),
                           Sys.getenv("MAPBOX_API"),
                           profile = "cycling")




rte = Routes$new(source = c(174.7691, -36.90049), dest = c(174.6455,-36.88731))

