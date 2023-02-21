# -------------------------------------------------------------------------------------------------------------------------
# map
library(raster)

# temp in deg Celsiues * 10
wc <- raster::getData('worldclim', res=0.5, var='bio', lat = 47.307490, lon = 12.907846)
aut <- getData('GADM', country='AUT', level=1)
#extat <- extent(aut)

# annual precipitation in austria
wcm <- mask(wc[[12]], aut)
preccol = brewer.pal(5, "YlGnBu")
pal <- colorRampPalette(preccol)
plot(wcm, xlim = c(9.5, 17.8), ylim = c(46,49.5), main = "Mean yearly precipitation in Austria", col = pal(100))

# elevation for austria
preccol = brewer.pal(5, "YlOrBr")
pal2 <- colorRampPalette(preccol)
elevr <- raster::getData('alt', country = "AUT")

# export
png("~/maps_austria.png", width = 1000, height = 1070)
par(mfrow = c(2, 1))
plot(wcm, xlim = c(9.5, 17.6), ylim = c(46.3,49.1), main = "Mean yearly precipitation in Austria", col = pal(100))
plot(elevr, xlim = c(9.5, 17.8), ylim = c(46, 49.5), col = pal2(100), main = "Altitude levels in Austria")
dev.off()