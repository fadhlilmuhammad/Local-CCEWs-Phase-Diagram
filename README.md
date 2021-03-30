# Local Wave Phase Diagram

Lubis SW, Respati MR. 2021. Impacts of convectively coupled equatorial waves on rainfall extremes in Java, Indonesia. International Journal of Climatology. 41(4): 2418-2440. [Link]( https://doi.org/10.1002/joc.6967)

1. Data folder includes netcdf file of wave-filtered daily outgoing longwave radiation (OLR) anomalies for Kelvin, equatorial Rossby (ER), and mixed Rossby-gravity (MRG) waves averaged over 5<sup>o</sup>S-9<sup>o</sup>S for the period of 1979-2018.
2. wave_phase_background.ncl includes the codes to generate background layout of the local wave phase diagram as in Fig. 3 in Lubis and Respati (2021).
3. local_wave_phase.ncl includes the codes to plot the standardized wave-filtered OLR anomalies and its temporal tendency onto the local wave phase diagram as in Fig. 3 in Lubis and Respati (2021).
4. olr_wave_filter.ncl includes the codes to perform wavenumber-frequency filter on daily OLR data for various modes of convectively coupled equatorial waves (CCEWs) as in Lubis and Respati (2021).

<p align="center">
  <img src="https://github.com/sandrolubis/Local-Phase-Diagram/blob/main/example/local_wave_phase_kelvin.png" width="300">
</p>

**Figure 1.** Local wave phase diagram of Kelvin waves over 110<sup>o</sup>E (central longitude of Java) from 01 November 1989 to 30 November 1989.

<p align="center">
  <img src="https://github.com/sandrolubis/Local-Phase-Diagram/blob/main/example/local_wave_phase_er.png" width="300">
</p>

**Figure 2.** Local wave phase diagram of equatorial Rossby (ER) waves over 110<sup>o</sup>E (central longitude of Java) from 01 November 1996 to 15 December 1996.

<p align="center">
  <img src="https://github.com/sandrolubis/Local-Phase-Diagram/blob/main/example/local_wave_phase_mrg.png" width="300">
</p>

**Figure 3.** Local wave phase diagram of mixed Rossby-gravity (MRG) waves over 110<sup>o</sup>E (central longitude of Java) from 01 February 1993 to 28 February 1993.
