; Author: Dr. Sandro Lubis (Jan 2020)
;         Local equatorial wave phase diagram
;         Lubis, SW, Respati, MR. Impacts of convectively coupled
;         equatorial waves on rainfall extremes in Java, Indonesia.
;         Int J Climatol. 2021; 41: 2418– 2440
; Contact: slubis.geomar@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "diag_local_wave_phase.ncl"

waves = (/"kelvin", "er", "mjo", "td", "mrg"/)


do i = 0, dimsizes(waves)-1
  dir = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/local_wave_phase/"
	figdir  = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/local_wave_phase/"
	fname = "waves.northAU.nc"

	opt = True
	opt@id = "145"
	opt@stdev_all = True
	; outname = "local_wave_phase_"+waves(i)+"_forwksum.nc"
	date_start  = 20161224
	date_end    = 20170110
	seas			  = "MJJASO"
	central_lon = toint(opt@id)
	NC				  = True
	PLOT			  = False

	local_phase_diag(dir,figdir,fname, waves(i),date_start,date_end,seas,central_lon,NC,PLOT, opt )
end do
