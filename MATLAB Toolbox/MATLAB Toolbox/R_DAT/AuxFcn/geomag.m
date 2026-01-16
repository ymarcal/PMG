function [DEC_V, DIP_V, TI_V, GV_V, EPOCH] = geomag(ALT_V, GLAT_V, GLON_V, TIME_V, MAXDEG)
%
%     [DEC, DIP, TI, GV, EPOCH] = geomag(ALT, GLAT, GLON, TIME, MAXDEG);
%     [deg, deg, nT, deg, year]         [ft , deg , deg , year,  adm  ]
% 
% C***********************************************************************
% C
% C
% C     SUBROUTINE GEOMAG (GEOMAGNETIC FIELD COMPUTATION)
% C
% C
% C***********************************************************************
% C
% C     GEOMAG IS A NATIONAL GEOSPATIAL INTELLIGENCE AGENCY (NGA) STANDARD
% C     PRODUCT.  IT IS COVERED UNDER NGA MILITARY SPECIFICATION:
% C     MIL-W-89500 (1993).
% C
% C***********************************************************************
% C     Contact Information
% C
% C     Software and Model Support
% C     	National Geophysical Data Center
% C     	NOAA EGC/2
% C     	325 Broadway
% C     	Boulder, CO 80303 USA
% C     	Attn: Susan McLean or Stefan Maus
% C     	Phone:  (303) 497-6478 or -6522
% C     	Email:  Susan.McLean@noaa.gov or Stefan.Maus@noaa.gov
% C		Web: http://www.ngdc.noaa.gov/seg/WMM/
% C
% C     Sponsoring Government Agency
% C	   National Geospatial-Intelligence Agency
% C    	   PRG / CSAT, M.S. L-41
% C    	   3838 Vogel Road
% C    	   Arnold, MO 63010
% C    	   Attn: Craig Rollins
% C    	   Phone:  (314) 263-4186
% C    	   Email:  Craig.M.Rollins@Nga.Mil
% C
% C      Original Program By:
% C        Dr. John Quinn
% C        FLEET PRODUCTS DIVISION, CODE N342
% C        NAVAL OCEANOGRAPHIC OFFICE (NAVOCEANO)
% C        STENNIS SPACE CENTER (SSC), MS 39522-5001
% C
%        Conversion to MATLAB By:
%          Cpt Eng Leonardo M. F. Lopes
%          BRAZILIAN AIR FORCE FLIGHT TEST RESEARCH INSTITUTE (IPEV)
%          DEPARTMENT OF AEROSPACE SCIENCE AND TECHNOLOGY (DCTA)
%          leonardo_ita01@yahoo.com.br
%          Sao Jose dos Campos, SP, Brazil. March 11th, 2011
% C
% C***********************************************************************
% C
% C     PURPOSE:  THIS ROUTINE COMPUTES THE DECLINATION (DEC),
% C               INCLINATION (DIP), TOTAL INTENSITY (TI) AND
% C               GRID VARIATION (GV - POLAR REGIONS ONLY, REFERENCED
% C               TO GRID NORTH OF A STEREOGRAPHIC PROJECTION) OF THE
% C               EARTH'S MAGNETIC FIELD IN GEODETIC COORDINATES
% C               FROM THE COEFFICIENTS OF THE CURRENT OFFICIAL
% C               DEPARTMENT OF DEFENSE (DOD) SPHERICAL HARMONIC WORLD
% C               MAGNETIC MODEL (WMM.COF).  THE WMM SERIES OF MODELS IS
% C               UPDATED EVERY 5 YEARS ON JANUARY 1ST OF THOSE YEARS
% C               WHICH ARE DIVISIBLE BY 5 (I.E. 2000, 2005, 2010 ETC.)
% C               BY NOAA'S NATIONAL GEOPHYSICAL DATA CENTER IN
% C               COOPERATION WITH THE BRITISH GEOLOGICAL SURVEY (BGS).
% C               THE MODEL IS BASED ON GEOMAGNETIC FIELD MEASUREMENTS
% C               FROM SATELLITE AND GROUND OBSERVATORIES.
% C
% C***********************************************************************
% C
% C     MODEL:  THE WMM SERIES GEOMAGNETIC MODELS ARE COMPOSED
% C             OF TWO PARTS:  THE MAIN FIELD MODEL, WHICH IS
% C             VALID AT THE BASE EPOCH OF THE CURRENT MODEL AND
% C             A SECULAR VARIATION MODEL, WHICH ACCOUNTS FOR SLOW
% C             TEMPORAL VARIATIONS IN THE MAIN GEOMAGNETIC FIELD
% C             FROM THE BASE EPOCH TO A MAXIMUM OF 5 YEARS BEYOND
% C             THE BASE EPOCH.  FOR EXAMPLE, THE BASE EPOCH OF
% C             THE WMM-2005 MODEL IS 2005.0.  THIS MODEL IS THEREFORE
% C             CONSIDERED VALID BETWEEN 2005.0 AND 2010.0. THE
% C             COMPUTED MAGNETIC PARAMETERS ARE REFERENCED TO THE
% C             WGS-84 ELLIPSOID.
% C
% C***********************************************************************
% C
% C     ACCURACY:  IN OCEAN AREAS AT THE EARTH'S SURFACE OVER THE
% C                ENTIRE 5 YEAR LIFE OF THE DEGREE AND ORDER 12
% C                SPHERICAL HARMONIC MODEL WMM-2005, THE ESTIMATED
% C                MAXIMUM RMS ERRORS FOR THE VARIOUS MAGNETIC COMPONENTS
% C                ARE:
% C
% C                DEC  -   0.5 Degrees
% C                DIP  -   0.5 Degrees
% C                TI   - 280.0 nanoTeslas (nT)
% C                GV   -   0.5 Degrees
% C
% C                OTHER MAGNETIC COMPONENTS THAT CAN BE DERIVED FROM
% C                THESE FOUR BY SIMPLE TRIGONOMETRIC RELATIONS WILL
% C                HAVE THE FOLLOWING APPROXIMATE ERRORS OVER OCEAN AREAS:
% C
% C                X    - 140 nT (North)
% C                Y    - 140 nT (East)
% C                Z    - 200 nT (Vertical) Positive is down
% C                H    - 200 nT (Horizontal)
% C
% C                OVER LAND THE MAXIMUM RMS ERRORS ARE EXPECTED TO BE
% C                HIGHER, ALTHOUGH THE RMS ERRORS FOR DEC, DIP, AND GV
% C                ARE STILL ESTIMATED TO BE LESS THAN 1.0 DEGREE, FOR
% C                THE ENTIRE 5-YEAR LIFE OF THE MODEL AT THE EARTH's
% C                SURFACE.  THE OTHER COMPONENT ERRORS OVER LAND ARE
% C                MORE DIFFICULT TO ESTIMATE AND SO ARE NOT GIVEN.
% C
% C                THE ACCURACY AT ANY GIVEN TIME FOR ALL OF THESE
% C                GEOMAGNETIC PARAMETERS DEPENDS ON THE GEOMAGNETIC
% C                LATITUDE.  THE ERRORS ARE LEAST FROM THE EQUATOR TO
% C                MID-LATITUDES AND GREATEST NEAR THE MAGNETIC POLES.
% C
% C                IT IS VERY IMPORTANT TO NOTE THAT A DEGREE AND
% C                ORDER 12 MODEL, SUCH AS WMM-2005, DESCRIBES ONLY
% C                THE LONG WAVELENGTH SPATIAL MAGNETIC FLUCTUATIONS
% C                DUE TO EARTH'S CORE.  NOT INCLUDED IN THE WMM SERIES
% C                MODELS ARE INTERMEDIATE AND SHORT WAVELENGTH
% C                SPATIAL FLUCTUATIONS OF THE GEOMAGNETIC FIELD
% C                WHICH ORIGINATE IN THE EARTH'S MANTLE AND CRUST.
% C                CONSEQUENTLY, ISOLATED ANGULAR ERRORS AT VARIOUS
% C                POSITIONS ON THE SURFACE (PRIMARILY OVER LAND, IN
% C                CONTINENTAL MARGINS AND OVER OCEANIC SEAMOUNTS,
% C                RIDGES AND TRENCHES) OF SEVERAL DEGREES MAY BE
% C                EXPECTED. ALSO NOT INCLUDED IN THE MODEL ARE
% C                NONSECULAR TEMPORAL FLUCTUATIONS OF THE GEOMAGNETIC
% C                FIELD OF MAGNETOSPHERIC AND IONOSPHERIC ORIGIN.
% C                DURING MAGNETIC STORMS, TEMPORAL FLUCTUATIONS CAN
% C                CAUSE SUBSTANTIAL DEVIATIONS OF THE GEOMAGNETIC
% C                FIELD FROM MODEL VALUES.  IN ARCTIC AND ANTARCTIC
% C                REGIONS, AS WELL AS IN EQUATORIAL REGIONS, DEVIATIONS
% C                FROM MODEL VALUES ARE BOTH FREQUENT AND PERSISTENT.
% C
% C                IF THE REQUIRED DECLINATION ACCURACY IS MORE
% C                STRINGENT THAN THE WMM SERIES OF MODELS PROVIDE, THEN
% C                THE USER IS ADVISED TO REQUEST SPECIAL (REGIONAL OR
% C                LOCAL) SURVEYS BE PERFORMED AND MODELS PREPARED.
% C                REQUESTS OF THIS NATURE SHOULD BE MADE TO NIMA
% C                AT THE ADDRESS ABOVE.
% C
% C***********************************************************************
% C
% C     USAGE:  THIS ROUTINE IS BROKEN UP INTO TWO PARTS:
% C
% C             A) AN INITIALIZATION MODULE, WHICH IS CALLED ONLY
% C                ONCE AT THE BEGINNING OF THE MAIN (CALLING)
% C                PROGRAM
% C             B) A PROCESSING MODULE, WHICH COMPUTES THE MAGNETIC
% C                FIELD PARAMETERS FOR EACH SPECIFIED GEODETIC
% C                POSITION (ALTITUDE, LATITUDE, LONGITUDE) AND TIME
% C
% C             INITIALIZATION IS MADE VIA A SINGLE CALL TO THE MAIN
% C             ENTRY POINT (GEOMAG), WHILE SUBSEQUENT PROCESSING
% C             CALLS ARE MADE THROUGH THE SECOND ENTRY POINT (GEOMG1).
% C             ONE CALL TO THE PROCESSING MODULE IS REQUIRED FOR EACH
% C             POSITION AND TIME.
% C
% C             THE VARIABLE MAXDEG IN THE INITIALIZATION CALL IS THE
% C             MAXIMUM DEGREE TO WHICH THE SPHERICAL HARMONIC MODEL
% C             IS TO BE COMPUTED.  IT MUST BE SPECIFIED BY THE USER
% C             IN THE CALLING ROUTINE.  NORMALLY IT IS 12 BUT IT MAY
% C             BE SET LESS THAN 12 TO INCREASE COMPUTATIONAL SPEED AT
% C             THE EXPENSE OF REDUCED ACCURACY.
% C
% C             THE PC VERSION OF THIS SUBROUTINE MUST BE COMPILED
% C             WITH A FORTRAN 77 COMPATIBLE COMPILER SUCH AS THE
% C             MICROSOFT OPTIMIZING FORTRAN COMPILER VERSION 4.1
% C             OR LATER.
% C
% C**********************************************************************
% C
% C     REFERENCES:
% C
% C       JOHN M. QUINN, DAVID J. KERRIDGE AND DAVID R. BARRACLOUGH,
% C            WORLD MAGNETIC CHARTS FOR 1985 - SPHERICAL HARMONIC
% C            MODELS OF THE GEOMAGNETIC FIELD AND ITS SECULAR
% C            VARIATION, GEOPHYS. J. R. ASTR. SOC. (1986) 87,
% C            PP 1143-1157
% C
% C       DEFENSE MAPPING AGENCY TECHNICAL REPORT, TR 8350.2:
% C            DEPARTMENT OF DEFENSE WORLD GEODETIC SYSTEM 1984,
% C            SEPT. 30 (1987)
% C
% C       JOHN M. QUINN, RACHEL J. COLEMAN, MICHAEL R. PECK, AND
% C            STEPHEN E. LAUBER; THE JOINT US/UK 1990 EPOCH
% C            WORLD MAGNETIC MODEL, TECHNICAL REPORT NO. 304,
% C            NAVAL OCEANOGRAPHIC OFFICE (1991)
% C
% C       JOHN M. QUINN, RACHEL J. COLEMAN, DONALD L. SHIEL, AND
% C            JOHN M. NIGRO; THE JOINT US/UK 1995 EPOCH WORLD
% C            MAGNETIC MODEL, TECHNICAL REPORT NO. 314, NAVAL
% C            OCEANOGRAPHIC OFFICE (1995)
% C
% C            SUSAN AMCMILLAN, DAVID R. BARRACLOUGH, JOHN M. QUINN, AND
% C            RACHEL J. COLEMAN;  THE 1995 REVISION OF THE JOINT US/UK
% C            GEOMAGNETIC FIELD MODELS - I. SECULAR VARIATION, JOURNAL OF
% C            GEOMAGNETISM AND GEOELECTRICITY, VOL. 49, PP. 229-243
% C            (1997)
% C
% C            JOHN M. QUINN, RACHEL J. COELMAN, SUSAM MACMILLAN, AND
% C            DAVID R. BARRACLOUGH;  THE 1995 REVISION OF THE JOINT
% C            US/UK GEOMAGNETIC FIELD MODELS: II. MAIN FIELD,JOURNAL OF
% C            GEOMAGNETISM AND GEOELECTRICITY, VOL. 49, PP. 245 - 261
% C            (1997)
% C
% C***********************************************************************
% C
% C     PARAMETER DESCRIPTIONS:
% C
% C       A      - SEMIMAJOR AXIS OF WGS-84 ELLIPSOID (KM)
% C       B      - SEMIMINOR AXIS OF WGS-84 ELLIPSOID (KM)
% C       RE     - MEAN RADIUS OF IAU-66 ELLIPSOID (KM)
% C       SNORM  - SCHMIDT NORMALIZATION FACTORS
% C       C      - GAUSS COEFFICIENTS OF MAIN GEOMAGNETIC MODEL (NT)
% C       CD     - GAUSS COEFFICIENTS OF SECULAR GEOMAGNETIC MODEL (NT/YR)
% C       TC     - TIME ADJUSTED GEOMAGNETIC GAUSS COEFFICIENTS (NT)
% C       OTIME  - TIME ON PREVIOUS CALL TO GEOMAG (YRS)
% C       OALT   - GEODETIC ALTITUDE ON PREVIOUS CALL TO GEOMAG (YRS)
% C       OLAT   - GEODETIC LATITUDE ON PREVIOUS CALL TO GEOMAG (DEG.)
% C       TIME   - COMPUTATION TIME (YRS)                        (INPUT)
% C                (EG. 1 JULY 1995 = 1995.500)
% C       ALT    - GEODETIC ALTITUDE (KM)                        (INPUT) -> changed to ft in MATLAB version
% C       GLAT   - GEODETIC LATITUDE (DEG.)                      (INPUT)
% C       GLON   - GEODETIC LONGITUDE (DEG.)                     (INPUT)
% C       EPOCH  - BASE TIME OF GEOMAGNETIC MODEL (YRS)
% C       DTR    - DEGREE TO RADIAN CONVERSION
% C       SP(M)  - SINE OF (M*SPHERICAL COORD. LONGITUDE)
% C       CP(M)  - COSINE OF (M*SPHERICAL COORD. LONGITUDE)
% C       ST     - SINE OF (SPHERICAL COORD. LATITUDE)
% C       CT     - COSINE OF (SPHERICAL COORD. LATITUDE)
% C       R      - SPHERICAL COORDINATE RADIAL POSITION (KM)
% C       CA     - COSINE OF SPHERICAL TO GEODETIC VECTOR ROTATION ANGLE
% C       SA     - SINE OF SPHERICAL TO GEODETIC VECTOR ROTATION ANGLE
% C       BR     - RADIAL COMPONENT OF GEOMAGNETIC FIELD (NT)
% C       BT     - THETA COMPONENT OF GEOMAGNETIC FIELD (NT)
% C       BP     - PHI COMPONENT OF GEOMAGNETIC FIELD (NT)
% C       P(N,M) - ASSOCIATED LEGENDRE POLYNOMIALS (UNNORMALIZED)
% C       PP(N)  - ASSOCIATED LEGENDRE POLYNOMIALS FOR M=1 (UNNORMALIZED)
% C       DP(N,M)- THETA DERIVATIVE OF P(N,M) (UNNORMALIZED)
% C       BX     - NORTH GEOMAGNETIC COMPONENT (NT)
% C       BY     - EAST GEOMAGNETIC COMPONENT (NT)
% C       BZ     - VERTICALLY DOWN GEOMAGNETIC COMPONENT (NT)
% C       BH     - HORIZONTAL GEOMAGNETIC COMPONENT (NT)
% C       DEC    - GEOMAGNETIC DECLINATION (DEG.)                (OUTPUT)
% C                  EAST=POSITIVE ANGLES
% C                  WEST=NEGATIVE ANGLES
% C       DIP    - GEOMAGNETIC INCLINATION (DEG.)                (OUTPUT)
% C                  DOWN=POSITIVE ANGLES
% C                    UP=NEGATIVE ANGLES
% C       TI     - GEOMAGNETIC TOTAL INTENSITY (NT)              (OUTPUT)
% C       GV     - GEOMAGNETIC GRID VARIATION (DEG.)             (OUTPUT)
% C                REFERENCED TO GRID NORTH
% C                GRID NORTH REFERENCED TO 0 MERIDIAN
% C                OF A POLAR STEREOGRAPHIC PROJECTION
% C                (ARCTIC/ANTARCTIC ONLY)
% C       MAXDEG - MAXIMUM DEGREE OF SPHERICAL HARMONIC MODEL    (INPUT)
% C       MOXORD - MAXIMUM ORDER OF SPHERICAL HARMONIC MODEL
% C
% C***********************************************************************
% C
% C     NOTE:  THIS VERSION OF GEOMAG USES A WMM SERIES GEOMAGNETIC
% C            FIELS MODEL REFERENCED TO THE WGS-84 GRAVITY MODEL
% C            ELLIPSOID
% C

% INPUT CHECK ------------------------------------------------------------

if nargin<4
    TIME_V = sum(clock.*[1 1/12 1/365 0 0 0]-[0 1/12 1/365 0 0 0]);
end
if nargin<5
    MAXDEG = 12;
end
if length(ALT_V) == 1 && length(GLAT_V) ~= 1
    ALT_V = ALT_V*ones(size(GLAT_V));
end
ALT_V = ALT_V * .3048/1000; % ft -> km
if length(TIME_V) == 1 && length(GLAT_V) ~= 1
    TIME_V = TIME_V*ones(size(GLAT_V));
end

%---------------------- MATLAB CODE------------------------%------------------------------- FORTRAN CODE-----------------------------
%                                                          %
%                                                          %
%                                                          % C***********************************************************************
%                                                          % C
%                                                          % C
%                                                          % C                        INITIALIZATION MODULE
%                                                          % C
%                                                          % C
%                                                          % C***********************************************************************
%                                                          % C
%                                                          % C
%                                                          %                                                          
%                                                          %       SUBROUTINE GEOMAG(MAXDEG,EPOCH)
%                                                          % C
%                                                          %       IMPLICIT NONE
%                                                          % C
%                                                          %       INTEGER MAXDEG
%                                                          %       REAL EPOCH
%                                                          % C
%                                                          %       INTEGER N, M, MAXORD, J
%                                                          %       REAL PI, DTR, A, B, RE, A2, B2, C2, A4, B4, C4
%                                                          %       REAL GNM, HNM, DGNM, DHNM, FLNMJ
%                                                          %       REAL OTIME, OALT, OLAT
%                                                          % C
%                                                          %       REAL C(0:12,0:12), CD(0:12,0:12)
%                                                          %       REAL P(0:12,0:12), DP(0:12,0:12), SNORM(0:12,0:12)
%                                                          %       REAL SP(0:12), CP(0:12), FN(0:12), FM(0:12), PP(0:12)
%                                                          %       REAL K(0:12,0:12)
%                                                          % C
%                                                          %       COMMON /INIT/ MAXORD, PI, DTR, A, B, RE, A2, B2, C2, A4, 
%                                                          %      1     B4, C4, OTIME, OALT, OLAT,
%                                                          %      2     C, CD, P, DP, SP, CP, FN, FM, PP, K
%                                                          % C
%                                                          %       CHARACTER*20 MODEL
%                                                          % C      EQUIVALENCE (SNORM,P)
%                                                          %
%                                                          %       OPEN (UNIT=9,FILE='WMM.COF')
%                                                          % C
%                                                          % C
%                                                          % C
%                                                          % C        INITIALIZE CONSTANTS
%                                                          % C
%                                                          % C
%                                                          % C
[EPOCH,WMM] = coef_read(TIME_V(1)); % read WMM coefs file  %       READ(9,1) EPOCH,MODEL
%                                                          %     1 FORMAT(4X,F6.1,5X,A)
if MAXDEG > 12, MAXDEG = 12; end                           %       IF (MAXDEG .GT. 12) MAXDEG=12
MAXORD = MAXDEG;                                           %       MAXORD=MAXDEG
%                                                          %       PI=3.14159265359
deg2rad = pi/180;                                          %       DTR=PI/180.0
SP(1)   = 0;                                               %       SP(0)=0.
CP(1)   = 1;                                               %       CP(0)=1.
P(1,1)  = 1;                                               %       P(0,0)=1.
PP(1)   = 1;                                               %       PP(0)=1.
DP(1,1) = 0;                                               %       DP(0,0)=0.
A  = 6378.137;                                             %       A=6378.137
B  = 6356.7523142;                                         %       B=6356.7523142
RE = 6371.2;                                               %       RE=6371.2
A2 = A^2;                                                  %       A2=A**2
B2 = B^2;                                                  %       B2=B**2
C2 = A2-B2;                                                %       C2=A2-B2
A4 = A2^2;                                                 %       A4=A2**2
B4 = B2^2;                                                 %       B4=B2**2
C4 = A4-B4;                                                %       C4=A4-B4
%                                                          % C
%                                                          % C      READ WORLD MAGNETIC MODEL SPHERICAL HARMONIC COEFFICIENTS
%                                                          % C
C(1,1)  = 0;                                               %       C(0,0)=0.0
CD(1,1) = 0;                                               %       CD(0,0)=0.0
%                                                          %     3 CONTINUE
N    = WMM(:,1)+1;                                         %       READ(9,4) N,M,GNM,HNM,DGNM,DHNM
M    = WMM(:,2)+1;                                         %     4 FORMAT(2(1X,I2),2(1X,F9.1),2(1X,F10.1))
GNM  = WMM(:,3);                                           %
HNM  = WMM(:,4);                                           %
DGNM = WMM(:,5);                                           %
DHNM = WMM(:,6);                                           %
%                                                          %       IF (N .EQ. 99) GO TO 5
for k = 1:length(N)                                        %
    if M(k) <= N(k)                                        %       IF (M .LE. N) THEN
        C(N(k),M(k))  = GNM(k);                            %       C(N,M)=GNM
        CD(N(k),M(k)) = DGNM(k);                           %       CD(N,M)=DGNM
        if M(k) ~= 1                                       %       IF (M .NE. 0) THEN
            C(M(k)-1,N(k))  = HNM(k);                      %       C(M-1,N)=HNM
            CD(M(k)-1,N(k)) = DHNM(k);                     %       CD(M-1,N)=DHNM
        end                                                %       ENDIF
    end                                                    %       ENDIF
end                                                        %
%                                                          %       GO TO 3
%                                                          %     5 CONTINUE
%                                                          %       CLOSE (UNIT=9)
%                                                          % C
%                                                          % C        CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED
%                                                          % C
SNORM(1,1) = 1;                                            %       SNORM(0,0)=1.
for N = 1:MAXORD                                           %       DO 20 N=1,MAXORD
    SNORM(N+1,1) = SNORM(N,1)*(2*N-1)/N;                   %       SNORM(N,0)=SNORM(N-1,0)*FLOAT(2*N-1)/FLOAT(N)
    J = 2;                                                 %       J=2
    for M = 0:N                                            %       DO 10 M=0,N
        K(N+1,M+1) = ((N-1)^2-M^2)/((2*N-1)*(2*N-3));      %       K(N,M)=FLOAT((N-1)**2-M**2)/FLOAT((2*N-1)*(2*N-3))
        if M > 0                                           %       IF (M .GT. 0) THEN
            FLNMJ = ((N-M+1)*J)/(N+M);                     %       FLNMJ=FLOAT((N-M+1)*J)/FLOAT(N+M)
            SNORM(N+1,M+1) = SNORM(N+1,M)*sqrt(FLNMJ);     %       SNORM(N,M)=SNORM(N,M-1)*SQRT(FLNMJ)
            J = 1;                                         %       J=1
            C(M,N+1) = SNORM(N+1,M+1)*C(M,N+1);            %       C(M-1,N)=SNORM(N,M)*C(M-1,N)
            CD(M,N+1) = SNORM(N+1,M+1)*CD(M,N+1);          %       CD(M-1,N)=SNORM(N,M)*CD(M-1,N)
        end                                                %       ENDIF
        C(N+1,M+1) = SNORM(N+1,M+1)*C(N+1,M+1);            %       C(N,M)=SNORM(N,M)*C(N,M)
        CD(N+1,M+1) = SNORM(N+1,M+1)*CD(N+1,M+1);          %       CD(N,M)=SNORM(N,M)*CD(N,M)
    end                                                    %    10 CONTINUE
    FN(N+1) = N+1;                                         %       FN(N)=FLOAT(N+1)
    FM(N+1) = N;                                           %       FM(N)=FLOAT(N)
end                                                        %    20 CONTINUE
K(2,2) = 0;                                                %       K(1,1)=0.
%                                                          % C
%                                                          % C
OTIME = -1000;                                             %       OTIME=-1000.
OALT  = -1000;                                             %       OALT=-1000.
OLAT  = -1000;                                             %       OLAT=-1000.
%                                                          % C
%                                                          % C
%                                                          %       RETURN
%                                                          %       END
%                                                          % C
%                                                          % C

% FUNCTION VECTORIZATION -----------------------------------

DEC_V  = zeros(size(ALT_V));
DIP_V  = zeros(size(ALT_V));
TI_V   = zeros(size(ALT_V));
GV_V   = zeros(size(ALT_V));

for n = 1:length(ALT_V)
    ALT  = ALT_V(n);
    GLON = GLON_V(n);
    GLAT = GLAT_V(n);
    TIME = TIME_V(n);
    %
    %                                                          % C***********************************************************************
    %                                                          % C
    %                                                          % C
    %                                                          % C                        PROCESSING MODULE
    %                                                          % C
    %                                                          % C
    %                                                          % C***********************************************************************
    %                                                          % C
    %                                                          % C
    %                                                          %       SUBROUTINE GEOMG1(ALT,GLAT,GLON,TIME,DEC,DIP,TI,GV,EPOCH)
    %                                                          % C
    %                                                          %       IMPLICIT NONE
    %                                                          % C
    %                                                          %       INTEGER N, M, MAXORD
    %                                                          %       REAL ALT, GLAT, GLON, TIME, DEC, DIP, TI, GV, EPOCH
    %                                                          %       REAL DT, RLON, RLAT, SRLON, SRLAT, CRLON, CRLAT
    %                                                          %       REAL SRLON2, SRLAT2, CRLON2, CRLAT2
    %                                                          %       REAL Q, Q1, Q2, CT, ST, R2, R, D, CA, SA, AOR, AR
    %                                                          %       REAL BR, BT, BP, BPP, PAR, TEMP1, TEMP2, PARP
    %                                                          %       REAL BX, BY, BZ, BH
    %                                                          % C
    %                                                          %       REAL PI, DTR, A, B, RE, A2, B2, C2, A4, B4, C4
    %                                                          %       REAL OTIME, OALT, OLAT
    %                                                          % C
    %                                                          %       REAL C(0:12,0:12), CD(0:12,0:12), TC(0:12,0:12)
    %                                                          %       REAL P(0:12,0:12), DP(0:12,0:12), SNORM(0:12,0:12)
    %                                                          %       REAL SP(0:12), CP(0:12), FN(0:12), FM(0:12), PP(0:12)
    %                                                          %       REAL K(0:12,0:12)
    %                                                          % C
    %                                                          %       COMMON /INIT/ MAXORD, PI, DTR, A, B, RE, A2, B2, C2, A4, 
    %                                                          %      1     B4, C4, OTIME, OALT, OLAT,
    %                                                          %      2     C, CD, P, DP, SP, CP, FN, FM, PP, K
    %                                                          % C
    %                                                          % C
    DT = TIME - EPOCH;                                         %       DT = TIME - EPOCH
    RLON = GLON*deg2rad;                                       %       RLON=GLON*DTR
    RLAT = GLAT*deg2rad;                                       %       RLAT=GLAT*DTR
    SRLON = sin(RLON);                                         %       SRLON=SIN(RLON)
    SRLAT = sin(RLAT);                                         %       SRLAT=SIN(RLAT)
    CRLON = cos(RLON);                                         %       CRLON=COS(RLON)
    CRLAT = cos(RLAT);                                         %       CRLAT=COS(RLAT)
    SRLON2 = SRLON^2;                                          %       SRLON2=SRLON**2
    SRLAT2 = SRLAT^2;                                          %       SRLAT2=SRLAT**2
    CRLON2 = CRLON^2;                                          %       CRLON2=CRLON**2
    CRLAT2 = CRLAT^2;                                          %       CRLAT2=CRLAT**2
    SP(2) = SRLON;                                             %       SP(1)=SRLON
    CP(2) = CRLON;                                             %       CP(1)=CRLON
    %                                                          % C
    %                                                          % C        CONVERT FROM GEODETIC COORDS. TO SPHERICAL COORDS.
    %                                                          % C
    Q  = sqrt(A2-C2*SRLAT2);                                   %       Q=SQRT(A2-C2*SRLAT2)
    Q1 = ALT*Q;                                                %       Q1=ALT*Q
    Q2 = ((Q1+A2)/(Q1+B2))^2;                                  %       Q2=((Q1+A2)/(Q1+B2))**2
    CT = SRLAT/sqrt(Q2*CRLAT2+SRLAT2);                         %       CT=SRLAT/SQRT(Q2*CRLAT2+SRLAT2)
    ST = sqrt(1-CT^2);                                         %       ST=SQRT(1.0-CT**2)
    R2 = ALT^2+2*Q1+(A4-C4*SRLAT2)/Q^2;                        %       R2=ALT**2+2.0*Q1+(A4-C4*SRLAT2)/Q**2
    R  = sqrt(R2);                                             %       R=SQRT(R2)
    D  = sqrt(A2*CRLAT2+B2*SRLAT2);                            %       D=SQRT(A2*CRLAT2+B2*SRLAT2)
    CA = (ALT+D)/R;                                            %       CA=(ALT+D)/R
    SA = C2*CRLAT*SRLAT/(R*D);                                 %       SA=C2*CRLAT*SRLAT/(R*D)
    %                                                          % C
    %                                                          % C
    for M = 2:MAXORD                                           %       DO 40 M=2,MAXORD
        SP(M+1) = SP(2)*CP(M)+CP(2)*SP(M);                     %       SP(M)=SP(1)*CP(M-1)+CP(1)*SP(M-1)
        CP(M+1) = CP(2)*CP(M)-SP(2)*SP(M);                     %       CP(M)=CP(1)*CP(M-1)-SP(1)*SP(M-1)
    end                                                        %    40 CONTINUE
    %                                                          % C
    %                                                          % C
    AOR = RE/R;                                                %       AOR=RE/R
    AR  = AOR^2;                                               %       AR=AOR**2
    %                                                          % C
    %                                                          % C
    BR  = 0;                                                   %       BR=0.
    BT  = 0;                                                   %       BT=0.
    BP  = 0;                                                   %       BP=0.
    BPP = 0;                                                   %       BPP=0.
    %                                                          % C
    %                                                          % C
    for N = 1:MAXORD                                           %       DO 70 N=1,MAXORD
        AR = AR*AOR;                                           %          AR=AR*AOR
        for M = 0:N                                            %           DO 60 M=0,N
            %                                                  % C     
            %                                                  % C     COMPUTE UNNORMALIZED ASSOCIATED LEGENDRE POLYNOMIALS
            %                                                  % C     AND DERIVATIVES VIA RECURSION RELATIONS
            %                                                  % C     
            if ALT ~= OALT || GLAT ~= OLAT                     %             IF (ALT .NE. OALT .OR. GLAT .NE. OLAT) THEN
                if N == M                                      %                IF (N .EQ. M) THEN
                    P(N+1,M+1) = ST*P(N,M);                    %                   P(N,M)=ST*P(N-1,M-1)
                    DP(N+1,M+1) = ST*DP(N,M)+CT*P(N,M);        %                   DP(N,M)=ST*DP(N-1,M-1)+CT*P(N-1,M-1)
                    %                                          %                   GO TO 50
                    %                                          %                ENDIF
                elseif N == 1 && M == 0                        %                IF (N .EQ. 1 .AND. M .EQ. 0) THEN
                    P(N+1,M+1)  = CT*P(N,M+1);                 %                   P(N,M)=CT*P(N-1,M)
                    DP(N+1,M+1) = CT*DP(N,M+1)-ST*P(N,M+1);    %                   DP(N,M)=CT*DP(N-1,M)-ST*P(N-1,M)
                    %                                          %                   GO TO 50
                    %                                          %                ENDIF
                elseif N > 1 && N ~= M                         %                IF (N .GT. 1 .AND. N .NE. M) THEN
                    if M > N-2, P(N-1,M+1)  = 0; end           %                   IF (M .GT. N-2) P(N-2,M)=0.0
                    if M > N-2, DP(N-1,M+1) = 0; end           %                   IF (M .GT. N-2) DP(N-2,M)=0.0
                    P(N+1,M+1) = CT*P(N,M+1)-K(N+1,M+1)*P(N-1,M+1);              % P(N,M)=CT*P(N-1,M)-K(N,M)*P(N-2,M)
                    DP(N+1,M+1)=CT*DP(N,M+1)-ST*P(N,M+1)-K(N+1,M+1)*DP(N-1,M+1); % DP(N,M)=CT*DP(N-1,M)-ST*P(N-1,M)-K(N,M)*DP(N-2,M)
                end                                            %                ENDIF
            end                                                %             ENDIF
            %                                                  %  50         CONTINUE
            %                                                  % C     
            %                                                  % C        TIME ADJUST THE GAUSS COEFFICIENTS
            %                                                  % C
            if TIME ~= OTIME                                   %             IF (TIME .NE. OTIME) THEN
                TC(N+1,M+1) = C(N+1,M+1)+DT*CD(N+1,M+1);       %                TC(N,M)=C(N,M)+DT*CD(N,M)
                if M ~= 0                                      %                IF (M .NE. 0) THEN
                    TC(M,N+1) = C(M,N+1)+DT*CD(M,N+1);         %                   TC(M-1,N)=C(M-1,N)+DT*CD(M-1,N)
                end                                            %                ENDIF
            end                                                %             ENDIF
            %                                                  % C     
            %                                                  % C        ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
            %                                                  % C
            PAR = AR*P(N+1,M+1);                               %             PAR=AR*P(N,M)
            if M == 0                                          %             IF (M .EQ. 0) THEN
                TEMP1 = TC(N+1,M+1)*CP(M+1);                   %                TEMP1=TC(N,M)*CP(M)
                TEMP2 = TC(N+1,M+1)*SP(M+1);                   %                TEMP2=TC(N,M)*SP(M)
            else                                               %             ELSE
                TEMP1 = TC(N+1,M+1)*CP(M+1)+TC(M,N+1)*SP(M+1); %                TEMP1=TC(N,M)*CP(M)+TC(M-1,N)*SP(M)
                TEMP2 = TC(N+1,M+1)*SP(M+1)-TC(M,N+1)*CP(M+1); %                TEMP2=TC(N,M)*SP(M)-TC(M-1,N)*CP(M)
            end                                                %             ENDIF
            BT = BT-AR*TEMP1*DP(N+1,M+1);                      %             BT=BT-AR*TEMP1*DP(N,M)
            BP = BP+FM(M+1)*TEMP2*PAR;                         %             BP=BP+FM(M)*TEMP2*PAR
            BR = BR+FN(N+1)*TEMP1*PAR;                         %             BR=BR+FN(N)*TEMP1*PAR
            %                                                  % C     
            %                                                  % C     SPECIAL CASE:  NORTH/SOUTH GEOGRAPHIC POLES
            %                                                  % C     
            if ST == 0 && M == 1                               %             IF (ST .EQ. 0.0 .AND. M .EQ. 1) THEN
                if N == 1                                      %                IF (N .EQ. 1) THEN
                    PP(N+1) = PP(N);                           %                   PP(N)=PP(N-1)
                else                                           %                ELSE
                    PP(N+1) = CT*PP(N)-K(N+1,M+1)*PP(N-1);     %                   PP(N)=CT*PP(N-1)-K(N,M)*PP(N-2)
                end                                            %                ENDIF
                PARP = AR*PP(N+1);                             %                PARP=AR*PP(N)
                BPP  = BPP+FM(M+1)*TEMP2*PARP;                 %                BPP=BPP+FM(M)*TEMP2*PARP
            end                                                %             ENDIF
            %                                                  % C     
            %                                                  % C     
        end %                                                  %  60      CONTINUE
    end %                                                      %  70   CONTINUE
    %                                                          % C
    %                                                          % C
    if ST == 0                                                 %       IF (ST .EQ. 0.0) THEN
        BP = BPP;                                              %       BP=BPP
    else                                                       %       ELSE
        BP = BP/ST;                                            %       BP=BP/ST
    end                                                        %       ENDIF
    %                                                          % C
    %                                                          % C        ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO
    %                                                          % C        GEODETIC COORDINATES
    %                                                          % C
    BX = -BT*CA-BR*SA;                                         %       BX=-BT*CA-BR*SA
    BY = BP;                                                   %       BY=BP
    BZ = BT*SA-BR*CA;                                          %       BZ=BT*SA-BR*CA
    %                                                          % C
    %                                                          % C        COMPUTE DECLINATION (DEC), INCLINATION (DIP) AND
    %                                                          % C        TOTAL INTENSITY (TI)
    %                                                          % C
    BH  = sqrt(BX^2+BY^2);                                     %       BH=SQRT(BX**2+BY**2)
    TI  = sqrt(BH^2+BZ^2);                                     %       TI=SQRT(BH**2+BZ**2)
    DEC = atan2(BY,BX)/deg2rad;                                %       DEC=ATAN2(BY,BX)/DTR
    DIP = atan2(BZ,BH)/deg2rad;                                %       DIP=ATAN2(BZ,BH)/DTR
    %                                                          % C
    %                                                          % C        COMPUTE MAGNETIC GRID VARIATION IF THE CURRENT
    %                                                          % C        GEODETIC POSITION IS IN THE ARCTIC OR ANTARCTIC
    %                                                          % C        (I.E. GLAT > +55 DEGREES OR GLAT < -55 DEGREES)
    %                                                          % C
    %                                                          % C        OTHERWISE, SET MAGNETIC GRID VARIATION TO -999.0
    %                                                          % C
    GV = NaN;                                                  %       GV=-999.0
    if abs(GLAT) >= 55                                         %       IF (ABS(GLAT) .GE. 55.) THEN
        if GLAT > 0 && GLON >= 0, GV = DEC-GLON;      end      %       IF (GLAT .GT. 0. .AND. GLON .GE. 0.) GV=DEC-GLON
        if GLAT > 0 && GLON <  0, GV = DEC+abs(GLON); end      %       IF (GLAT .GT. 0. .AND. GLON .LT. 0.) GV=DEC+ABS(GLON)
        if GLAT < 0 && GLON >= 0, GV = DEC+GLON;      end      %       IF (GLAT .LT. 0. .AND. GLON .GE. 0.) GV=DEC+GLON
        if GLAT < 0 && GLON <  0, GV = DEC-abs(GLON); end      %       IF (GLAT .LT. 0. .AND. GLON .LT. 0.) GV=DEC-ABS(GLON)
        if GV > +180, GV = GV-360; end                         %       IF (GV .GT. +180.) GV=GV-360.
        if GV < -180, GV = GV+360; end                         %       IF (GV .LT. -180.) GV=GV+360.
    end                                                        %       ENDIF
    %                                                          % C
    %                                                          % C
    OTIME = TIME;                                              %       OTIME=TIME
    OALT  = ALT;                                               %       OALT=ALT
    OLAT  = GLAT;                                              %       OLAT=GLAT
    %                                                          % C
    %                                                          % C
    %                                                          %       RETURN
    %                                                          %       END
    %                                                          %
    DEC_V(n)  = DEC;
    DIP_V(n)  = DIP;
    TI_V(n)   = TI;
    GV_V(n)   = GV;
end
%
% ----------------------------------------------------------
function [EPOCH,WMM] = coef_read(yr)
% Read coefficients file

epoch = yr - rem(yr,5);

fname = ['WMM' num2str(epoch) '.COF'];
if ~exist(fname,'file')
    fname = 'WMM.COF';
end
if ~exist(fname,'file')
    for Y = 2020:-5:1990
        fname = ['WMM' num2str(Y) '.COF'];;
        if exist(fname,'file')
            break
        end
    end
end
if ~exist(fname,'file')
    disp(' ');
    error('Coefficients file not found.')
    disp(' ');
end

fid = fopen(fname,'r');
hdr = fgetl(fid);

EPOCH = str2num(hdr(1:15));

if EPOCH ~= epoch
    disp(' ');
    disp(['Warning: Valid coefficients file for year ' num2str(fix(yr)) ' not found (' num2str(epoch) ' epoch).']);
    disp(['         Using current coefficients file instead (' num2str(EPOCH) ' epoch).']);
end

WMM = [];
go = 1;

while go
    S = fgetl(fid);
    if ~strcmp(S(1:4),'9999')
        L = str2num(S);
        WMM = [WMM; L];
    else
        go = 0;
    end
end

fclose(fid);