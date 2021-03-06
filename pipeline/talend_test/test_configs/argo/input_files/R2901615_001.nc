CDF      
      	DATE_TIME         	STRING256         STRING64   @   STRING32       STRING16      STRING8       STRING4       STRING2       N_PROF        N_PARAM       N_LEVELS   \   N_CALIB       	N_HISTORY                     <   	DATA_TYPE                  comment       	Data type      
_FillValue                    0�   FORMAT_VERSION                 comment       File format version    
_FillValue                    0�   HANDBOOK_VERSION               comment       Data handbook version      
_FillValue                    0�   REFERENCE_DATE_TIME                 comment       !Date of reference for Julian days      conventions       YYYYMMDDHHMISS     
_FillValue                    1    DATE_CREATION                   comment       Date of file creation      conventions       YYYYMMDDHHMISS     
_FillValue                    1   DATE_UPDATE                 	long_name         Date of update of this file    conventions       YYYYMMDDHHMISS     
_FillValue                    1    PLATFORM_NUMBER                   	long_name         Float unique identifier    conventions       WMO float identifier : A9IIIII     
_FillValue                    10   PROJECT_NAME                  comment       Name of the project    
_FillValue                  @  18   PI_NAME                   comment       "Name of the principal investigator     
_FillValue                  @  1x   STATION_PARAMETERS           	            	long_name         ,List of available parameters for the station   conventions       Argo reference table 3     
_FillValue                  0  1�   CYCLE_NUMBER               	long_name         Float cycle number     conventions       <0..N, 0 : launch cycle (if exists), 1 : first complete cycle   
_FillValue         ��        1�   	DIRECTION                  	long_name         !Direction of the station profiles      conventions       -A: ascending profiles, D: descending profiles      
_FillValue                    1�   DATA_CENTRE                   	long_name         .Data centre in charge of float data processing     conventions       Argo reference table 4     
_FillValue                    1�   DC_REFERENCE                  	long_name         (Station unique identifier in data centre   conventions       Data centre convention     
_FillValue                     1�   DATA_STATE_INDICATOR                  	long_name         1Degree of processing the data have passed through      conventions       Argo reference table 6     
_FillValue                    2   	DATA_MODE                  	long_name         Delayed mode or real time data     conventions       >R : real time; D : delayed mode; A : real time with adjustment     
_FillValue                    2   INST_REFERENCE                    	long_name         Instrument type    conventions       Brand, type, serial number     
_FillValue                  @  2   WMO_INST_TYPE                     	long_name         Coded instrument type      conventions       Argo reference table 8     
_FillValue                    2\   JULD               	long_name         ?Julian day (UTC) of the station relative to REFERENCE_DATE_TIME    units         "days since 1950-01-01 00:00:00 UTC     conventions       8Relative julian days with decimal part (as parts of day)   
_FillValue        A.�~            2`   JULD_QC                	long_name         Quality on Date and Time   conventions       Argo reference table 2     
_FillValue                    2h   JULD_LOCATION                  	long_name         @Julian day (UTC) of the location relative to REFERENCE_DATE_TIME   units         "days since 1950-01-01 00:00:00 UTC     conventions       8Relative julian days with decimal part (as parts of day)   
_FillValue        A.�~            2l   LATITUDE               	long_name         &Latitude of the station, best estimate     units         degree_north   
_FillValue        @�i�       	valid_min         �V�        	valid_max         @V�             2t   	LONGITUDE                  	long_name         'Longitude of the station, best estimate    units         degree_east    
_FillValue        @�i�       	valid_min         �f�        	valid_max         @f�             2|   POSITION_QC                	long_name         ,Quality on position (latitude and longitude)   conventions       Argo reference table 2     
_FillValue                    2�   POSITIONING_SYSTEM                    	long_name         Positioning system     
_FillValue                    2�   PROFILE_PRES_QC                	long_name         #Global quality flag of PRES profile    conventions       Argo reference table 2a    
_FillValue                    2�   PROFILE_PSAL_QC                	long_name         #Global quality flag of PSAL profile    conventions       Argo reference table 2a    
_FillValue                    2�   PROFILE_TEMP_QC                	long_name         #Global quality flag of TEMP profile    conventions       Argo reference table 2a    
_FillValue                    2�   PRES         
      	   	long_name         SEA PRESSURE   
_FillValue        G�O�   units         decibar    	valid_min                	valid_max         F;�    comment       $In situ measurement, sea surface = 0   C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���     p  2�   PRES_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  4   PRES_ADJUSTED            
      	   	long_name         SEA PRESSURE   
_FillValue        G�O�   units         decibar    	valid_min                	valid_max         F;�    comment       $In situ measurement, sea surface = 0   C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���     p  4h   PRES_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  5�   PRES_ADJUSTED_ERROR          
         	long_name         SEA PRESSURE   
_FillValue        G�O�   units         decibar    comment       WContains the error on the adjusted values as determined by the delayed mode QC process.    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���     p  64   PSAL         
      	   	long_name         PRACTICAL SALINITY     
_FillValue        G�O�   units         psu    	valid_min                	valid_max         B(     comment       In situ measurement    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  7�   PSAL_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  9   PSAL_ADJUSTED            
      	   	long_name         PRACTICAL SALINITY     
_FillValue        G�O�   units         psu    	valid_min                	valid_max         B(     comment       In situ measurement    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  9p   PSAL_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  :�   PSAL_ADJUSTED_ERROR          
         	long_name         PRACTICAL SALINITY     
_FillValue        G�O�   units         psu    comment       WContains the error on the adjusted values as determined by the delayed mode QC process.    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  ;<   TEMP         
      	   	long_name         $SEA TEMPERATURE IN SITU ITS-90 SCALE   
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      comment       In situ measurement    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  <�   TEMP_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  >   TEMP_ADJUSTED            
      	   	long_name         $SEA TEMPERATURE IN SITU ITS-90 SCALE   
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      comment       In situ measurement    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  >x   TEMP_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  \  ?�   TEMP_ADJUSTED_ERROR          
         	long_name         $SEA TEMPERATURE IN SITU ITS-90 SCALE   
_FillValue        G�O�   units         degree_Celsius     comment       WContains the error on the adjusted values as determined by the delayed mode QC process.    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o     p  @D   	PARAMETER               	            	long_name         /List of parameters with calibration information    conventions       Argo reference table 3     
_FillValue                  0  A�   SCIENTIFIC_CALIB_EQUATION               	            	long_name         'Calibration equation for this parameter    
_FillValue                    A�   SCIENTIFIC_CALIB_COEFFICIENT            	            	long_name         *Calibration coefficients for this equation     
_FillValue                    D�   SCIENTIFIC_CALIB_COMMENT            	            	long_name         .Comment applying to this parameter calibration     
_FillValue                    G�   CALIBRATION_DATE            	             
_FillValue                  ,  J�   HISTORY_INSTITUTION                      	long_name         "Institution which performed action     conventions       Argo reference table 4     
_FillValue                    K   HISTORY_STEP                     	long_name         Step in data processing    conventions       Argo reference table 12    
_FillValue                    K   HISTORY_SOFTWARE                     	long_name         'Name of software which performed action    conventions       Institution dependent      
_FillValue                    K   HISTORY_SOFTWARE_RELEASE                     	long_name         2Version/release of software which performed action     conventions       Institution dependent      
_FillValue                    K   HISTORY_REFERENCE                        	long_name         Reference of database      conventions       Institution dependent      
_FillValue                  @  K    HISTORY_DATE                      	long_name         #Date the history record was created    conventions       YYYYMMDDHHMISS     
_FillValue                    K`   HISTORY_ACTION                       	long_name         Action performed on data   conventions       Argo reference table 7     
_FillValue                    Kp   HISTORY_PARAMETER                        	long_name         (Station parameter action is performed on   conventions       Argo reference table 3     
_FillValue                    Kt   HISTORY_START_PRES                    	long_name          Start pressure action applied on   
_FillValue        G�O�   units         decibar         K�   HISTORY_STOP_PRES                     	long_name         Stop pressure action applied on    
_FillValue        G�O�   units         decibar         K�   HISTORY_PREVIOUS_VALUE                    	long_name         +Parameter/Flag previous value before action    
_FillValue        G�O�        K�   HISTORY_QCTEST                       	long_name         <Documentation of tests performed, tests failed (in hex form)   conventions       EWrite tests performed when ACTION=QCP$; tests failed when ACTION=QCF$      
_FillValue                    K�Argo profile    2.2 1.2 19500101000000  20120110125211  20120110125211  2901615 Argo China SOA                                                  Fengying Ji                                                     PRES            PSAL            TEMP               A   NM                                  2C  R   PROVOR- SBE41CP                                                 841 @���8Q�1   @���8Q�@<� ě��@a�333331   ARGOS   A   A   A       @�  Ap  A�  B  B8  B`  B�  B�  B�  B�  B�  B�  B�  C  C  C  C&  C0  C:  CD  CV  Cq  C�� C�  C�� C�  C�� C�  C΀ C�  C� C�  D @ D� D  D@ D@ D� D%� D,  D2@ D8� D>� DE  DK@ DQ� DX  D^@ Dd� Dj� Dq@ Dw  D}@ D�� D�� D�  D�  D�@ D�� D�� D�� D�� D�� D�  D�  D�@ D�` D�� D�� D�� D�  D�  D�  D�` D�` DƠ D�� D�� D�� D�  D�` D�` D�` D߀ D�� D�� D�� D�� D�  D�@ D�` 11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111    @�  Ap  A�  B  B8  B`  B�  B�  B�  B�  B�  B�  B�  C  C  C  C&  C0  C:  CD  CV  Cq  C�� C�  C�� C�  C�� C�  C΀ C�  C� C�  D @ D� D  D@ D@ D� D%� D,  D2@ D8� D>� DE  DK@ DQ� DX  D^@ Dd� Dj� Dq@ Dw  D}@ D�� D�� D�  D�  D�@ D�� D�� D�� D�� D�� D�  D�  D�@ D�` D�� D�� D�� D�  D�  D�  D�` D�` DƠ D�� D�� D�� D�  D�` D�` D�` D߀ D�� D�� D�� D�� D�  D�@ D�` 11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��@��B"�B>wBZBS�Br�By�B�B�VB�VB�PB�%Bs�B`BBS�BA�B2-B&�B�B�B�B+B
�B
�yB
�
B
ƨB
�9B
��B
�7B
jB
@�B
�B	�yB	�9B	�B	P�B	!�B	1B�BB��B�LB��B�{B�oB��B��B�B�LB�B�`B��B	oB	�B	%�B	7LB	M�B	`BB	v�B	� B	�PB	��B	��B	��B	�!B	�RB	��B	ƨB	��B	��B	�#B	�NB	�B	�B	��B
B
+B
DB
uB
�B
#�B
)�B
0!B
49B
9XB
@�B
D�B
I�B
L�B
O�B
Q�B
T�B
YB
]/11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111B�B5�BQ@BKBi�Bq B|CB�zB�{B�uB}KBj�BWlBK$B8�B)\BB�B�B�B
�^B
��B
�B
�CB
��B
�vB
�
B
�xB
a�B
7�B
�B	��B	��B	|B	HKB	8B��B׸B�QB��B�B��B��B�(B�_B��B��BњB��B�[B		�B	�B	YB	.�B	EFB	W�B	n8B	woB	��B	��B	�$B	�[B	��B	��B	��B	�B	�;B	�`B	ҊB	ٵB	��B	�B	�@B	�kB	��B
�B

�B
	B
9B
!^B
'�B
+�B
0�B
7�B
;�B
AB
D,B
G>B
IKB
L\B
PuB
T�11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
<#�
A�uA�M�Aٛ�A��;A�S�A���A�z�A�A���A�1'A�$�A�r�A�VA�p�A��A��HA��;A�O�A��#A�^5A��+A���A�
=A�ƨA�(�A���A��A�^5Ax��AnbNAdffAYdZAL�AA��A4�A%�TA�AC�AdZA$�@�z�@�z�@̣�@��@�x�@�j@���@��`@�ȴ@�;d@�ƨ@�v�@�$�@�7L@w�@n�@b�H@_K�@Y�^@U�@Q��@M?}@I�^@F{@A��@?��@<�@9��@7
=@3�m@/K�@-�@(bN@%�@"��@!&�@{@o@�@�/@@X@�y@��@
��@��@�;@�y@{@�@"�@J11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111A�uA�M�Aٛ�A��;A�S�A���A�z�A�A���A�1'A�$�A�r�A�VA�p�A��A��HA��;A�O�A��#A�^5A��+A���A�
=A�ƨA�(�A���A��A�^5Ax��AnbNAdffAYdZAL�AA��A4�A%�TA�AC�AdZA$�@�z�@�z�@̣�@��@�x�@�j@���@��`@�ȴ@�;d@�ƨ@�v�@�$�@�7L@w�@n�@b�H@_K�@Y�^@U�@Q��@M?}@I�^@F{@A��@?��@<�@9��@7
=@3�m@/K�@-�@(bN@%�@"��@!&�@{@o@�@�/@@X@�y@��@
��@��@�;@�y@{@�@"�@J99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;o;oPRES            TEMP            PSAL            none                                                                                                                                                                                                                                                            none                                                                                                                                                                                                                                                            PSAL_ADJUSTED is calculated from a conductivity multiplicative adjustment term r.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               r = 0.9999 (+/0.0001)                                                                                                                                                                                                                                           Calibration error is manufacturers specified PRES accuracy at time of lab calibration                                                                                                                                                                           Calibration error is manufacturers specified TEMP accuracy at time of lab calibration                                                                                                                                                                           No salinity adjustment needed according to OW1.1. Ref. Data are CTD_for_DMQC_2013V01+ARGO_for_DMQC_2013V01                                                                                                                                                                                  20130630        NM  ARGQNMRT1.0 WOA09                                                           20120705010101  QCP$PSAL            G�O�G�O�G�O�FFBFE           NM  ARSQOW  1.1                                                                 20130630000000  CV  PSAL            G�O�G�O�G�O�                