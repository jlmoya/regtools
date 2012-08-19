mode(1)
//
// Demo of qqplot.sci
//
// Example from the R package (www.r.org).
// Precipitation in US Cities, (Statistical Abstracts of the United States, 1975.).
precip=[67.0, 54.7,  7.0, 48.5, 14.0, 17.2, 20.7, 13.0, 43.4, 40.2, 38.9, 54.5, 59.8, 48.3, 22.9,..
11.5, 34.4, 35.1, 38.7, 30.8, 30.6, 43.1, 56.8, 40.8, 41.8, 42.5, 31.0, 31.7, 30.2, 25.9,..
49.2, 37.0, 35.9, 15.0, 30.2,  7.2, 36.2, 45.5,  7.8, 33.4, 36.1, 40.2, 42.7, 42.5, 16.2,..
39.0, 35.0, 37.0, 31.4, 37.6, 39.9, 36.2, 42.8, 46.4, 24.7, 49.1, 46.0, 35.9,  7.8, 48.2,..
15.2, 32.5, 44.7, 42.6, 38.8, 17.4, 40.8, 29.1, 14.6, 59.2];
scf(); qqplot(precip) // compare with a N(0,1) distribution.
ylabel('Precipitation in 70 US cities [in/yr]');
//========= E N D === O F === D E M O =========//
