#' Function to return the MH24 hydrologic indicator statistic for a given data frame
#' 
#' This function accepts a data frame that contains a column named "discharge" and 
#' calculates MH24, high peak flow. Compute the average peak flow value for flow events above a threshold equal 
#' to the median flow for the entire record. MH24 is the average peak flow divided by the median flow for the 
#' entire record (dimensionless-temporal).
#' 
#' @param qfiletempf data frame containing a "discharge" column containing daily flow values
#' @return mh24 numeric value of MH24 for the given data frame
#' @export
#' @examples
#' qfiletempf<-sampleData
#' mh24(qfiletempf)
mh24 <- function(qfiletempf) {
  hfcrit <- ma2(qfiletempf)
  noyears <- aggregate(qfiletempf$discharge, list(qfiletempf$wy_val), 
                       FUN = median, na.rm=TRUE)
  colnames(noyears) <- c("Year", "momax")
  noyrs <- length(noyears$Year)
  peak <- rep(0,nrow(qfiletempf))
  flag <- 0
  nevents <- 0
  for (i in 1:noyrs) {
    subsetyr <- subset(qfiletempf, as.numeric(qfiletempf$wy_val) == noyears$Year[i])
    for (j in 1:nrow(subsetyr)) {
      if (subsetyr$discharge[j]>hfcrit) {
        flag <- flag+1
        temp <- subsetyr$discharge[j]
        nevents <- ifelse(flag==1,nevents+1,nevents)
        peak[nevents] <- ifelse(temp>peak[nevents],temp,peak[nevents])
      } else {flag <- 0}
    }
  }
  peak_sub <- subset(peak,peak>0)
  meanex <- mean(peak_sub)
  mh24 <- round(meanex/ma2(qfiletempf),digits=2)
  return(mh24)
}