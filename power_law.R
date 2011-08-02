
graph <- GetGraph(file=my.files[20])
x <- degree(graph) + 1

FitPowerLaw <- function(x) {
  require(VGAM)
  x <-  as.integer(x)

  # Range of scaling parameters
  vec <- seq(1.5, 3.5, 0.01)
  zvec <- zeta(vec)

  xmins <- sort(unique(x))
  # limit <- c()
  xmins <- xmins[-length(xmins)]
  xmax <- max(x)
  dat <- matrix(0, nrow=length(xmins), ncol=2)
  z <- x

  for (i in 1:length(xmins)) {
    xmin <- xmins[i]
    z <- z[z >= xmin]
    n <- length(z)
    # Use maximization of likelihood function to estimate alpha
    if (xmin == 1) {
      zdiff <- rep(1, length(vec))
    } else {
      zdiff <- apply(X=rep(t(1:(xmin-1)), length(vec))^-
 		     t(kronecker(t(array(1, xmin - 1)), vec)), MARGIN=2, FUN=sum)
    }
    L <- -vec * sum(log(z)) - n * log(zvec - zdiff)
    I <- which.max(L)
    # Compute KS statistic
    fit <- cumsum((((xmin:xmax)^-vec[I])) / 
		  (zvec[I] - sum((1:(xmin-1))^-vec[I])))
    cdi <- cumsum(hist(z, c(min(z) - 1, (xmin + 0.5):xmax, max(z) + 1),
		       plot=FALSE)$counts / n)
    dat[i, ] <- c(max(abs(fit - cdi)), vec[I])
  }

  D <- min(dat[, 1])
  I <- which.min(dat[, 1])
  xmin <- xmins[I]
  n <- sum(x >= xmin)
  alpha <- dat[I, 2]
}
