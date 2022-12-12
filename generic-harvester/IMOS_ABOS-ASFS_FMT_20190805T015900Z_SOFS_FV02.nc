CDF      
      TIME       h_string   �   h_num            .   project       "Integrated Marine Observing System     conventions       IMOS version 1.3   title         =Heat and radiative flux data from Southern Ocean Flux Station      institution        Australian Bureau of Meteorology   date_created      2019-08-06T00:25:03Z   abstract             comment       �COARE Bulk Flux Algorithm version 3.0b (Fairall et 
al.,2003: J.Climate,16,571-591). Net heat flux does not include flux due to a rainfall (H_RAIN).   source        Mooring observation    keywords     �Oceans>Ocean Temperature>Sea Surface 
Temperature,Oceans>Ocean Winds>Surface Winds,Atmosphere>Atmospheric 
Pressure>Atmospheric 
Pressure,Atmosphere>Precipitation>Precipitation Rate,Atmosphere>Atmospheric 
Water Vapor>Humidity,Atmosphere>Atmospheric Winds>Surface 
Winds,Atmosphere>Atmospheric Temperature>Air Temperature,Atmosphere>Atmospheric 
Radiation>Shortwave Radiation,Atmosphere>Atmospheric Radiation>Longwave 
Radiation,Atmosphere>Atmospheric Radiation>Net Radiation,Atmosphere>Atmospheric 
Radiation>Radiative Flux,Oceans>Ocean Heat Budget>Heat Flux,Oceans>Ocean 
Heat Budget>Longwave Radiation,Oceans>Ocean Heat Budget>Shortwave Radiation      
references        http://www.imos.org.au     netcdf_version        3.6.1      platform_code         SOFS   naming_authority      IMOS   cdm_data_type         
Trajectory     geospatial_lat_min                -46.90580      geospatial_lat_max                -46.89960      geospatial_lon_min                142.38600      geospatial_lon_max                142.39101      geospatial_vertical_min       0.0    geospatial_vertical_max       0.0    time_coverage_start       2019-08-05T01:59:00Z   time_coverage_end         2019-08-05T23:59:00Z   data_centre       'eMII eMarine Information Infrastructure    data_center_email         info@emii.org.au   author_email      janice.sisson@bom.gov.au   author        Janice Sisson      principal_investigator        Eric Schulz    citation      �Citation to be used in publications should follow 
the format: 'IMOS.[year-of-data-download],[Title],[Data access URL],accessed 
[date-of access]'     acknowledgement       �Data was sourced from Integrated Marine 
Observing System (IMOS) - an initiative of the Australian Government being 
conducted as part of the National Calloborative Research Infrastructure 
Strategy.    distribution_statement       ABOS data may be re-used, provided 
that related metadata explaining the data has been reviewed by the user, and the 
data is appropriately acknowledged. Data, products and services from IMOS are 
provided 'as is' without any warranty as to fitness for a particular purpose.     file_version      Level 2 - Derived product      file_version_quality_control      �All data in this file has been 
through the BOM quality control procedure (Reference Table F) and was classed Z 
(passes all tests)    site      SOUTHERN OCEAN FLUX STATION    WMO       58450      zi        600.0      
zi_comment        9atmospheric boundary layer depth used in 
calcalutions, m      jcool         1      jcool_comment         81 - cool skin calculated, 0 - measured by IR 
radiometer   jwarm         1      jwarm_comment         91 - warm layer calculated, 0 - measured by IR 
radiometer      jwave         0      jwave_comment         ewave state option: 0 - Charnock (Smith, 1988), 
1 - Oost et al. (2001), 2 - Taylor and Yelland (2000)      data_comment      Hfor complete list of instruments see corresponding file version 1 (FV01)   deployment_number         
               system1       fimei300234063796850-L25-U2,V2,DIR2,SPD2,SPD4,P2,T2,RH2,TS2,CNDC2,SSPS2,PRECIP2,RAD_SW2,RAD_LW2,PL_CMP2     system2       Ximei300234064902590-L26-U,V,DIR,SPD,SPD3,P,T,RH,TS,CNDC,SSPS,PRECIP,RAD_SW,RAD_LW,PL_CMP      ,   TIME                standard_name         time   	long_name         time   units         days since 1950-01-01 00:00:00Z    axis      T      	valid_min                	valid_max         @��        
_FillValue        �Ç�       comment       :Relative julian days with decimal part as parts of the day          A�   LATITUDE                standard_name         latitude   	long_name         latitude   units         degrees_north      axis      Y      	valid_min         ����   	valid_max            Z   
_FillValue        �<    reference_datum       geographical coordinates, WGS84         A�   	LONGITUDE                   standard_name         	longitude      	long_name         	longitude      units         degrees_east   axis      X      	valid_min         ���L   	valid_max            �   
_FillValue        �<    reference_datum       geographical coordinates, WGS84         A�   PL_CMP                  	long_name         compass direction      units         degrees_north      observation_type      measured   
_FillValue        �<         A�   WDIR                standard_name         wind_to_direction      	long_name         -earth relative wind direction (oceanographic)      units         degree     
_FillValue        �<    observation_type      
calculated     comment       Cwind direction is calculated from observed wind vectors and compass         A�   WSPD                standard_name         
wind_speed     	long_name         earth relative wind speed      units         meter second-1     
_FillValue        �<    observation_type      
calculated     comment       ?wind speed is calculated from observed wind vectors and compass         A�   WIND_H                  	long_name         )wind measurement height above water level      units         meter           A�   	WIND_FLAG                   	long_name         wind sensor flag   comment       1 - system1, 2 - system2        A�   ATMP                standard_name         air_pressure   	long_name         atmospheric pressure   units         hectopascal    
_FillValue        �<    mslp_indicator        at sensor height   observation_type      measured        A�   ATMP_H                  	long_name         9atmospheric pressure measurement height above water level      units         meter           A�   	ATMP_FLAG                   	long_name          atmospheric pressure sensor flag   comment       1 - system1, 2 - system2        A�   AIRT                standard_name         air_temperature    	long_name         air temperature    units         celsius    
_FillValue        �<    observation_type      measured        A�   AIRT_H                  	long_name         4air temperature measurement height above water level   units         meter           A�   	AIRT_FLAG                   	long_name         air temperature sensor flag    comment       1 - system1, 2 - system2        A�   RELH                standard_name         relative_humidity      	long_name         relative humidity      units         percent    
_FillValue        �<    observation_type      measured        A�   RELH_H                  	long_name         6relative humidity measurement height above water level     units         meter           A�   	RELH_FLAG                   	long_name         relative humidity sensor flag      comment       1 - system1, 2 - system2        A�   TEMP                standard_name         sea_water_temperature      	long_name         sea water temperature      units         celsius    
_FillValue        �<    observation_type      measured        A�   TEMP_H                  	long_name         'sea water temperature measurement depth    units         meter           A�   	TEMP_FLAG                   	long_name         !sea water temperature sensor flag      comment       1 - system1, 2 - system2        A�   RAIN_AMOUNT                 standard_name         rainfall_rate      	long_name         	rain rate      units         millimeters hour-1     
_FillValue        �<    observation_type      measured        A�   RAIN_AMOUNT_H                   	long_name         2precipitation measurement height above water level     units         meter           A�   RAIN_AMOUNT_FLAG                	long_name         precipitation sensor flag      comment       1 - system1, 2 - system2        A�   SW                  standard_name         )surface_downwelling_shortwave_flux_in_air      	long_name         short wave radiation   units         watts meter-2      
_FillValue        �<    observation_type      measured        A�   SW_H                	long_name         9short-wave radiation measurement height above water level      units         meter           B    SW_FLAG                 	long_name          short-wave radiation sensor flag   comment       1 - system1, 2 - system2        B   LW                  standard_name         (surface_downwelling_longwave_flux_in_air   	long_name         long wave radiation    units         watts meter-2      
_FillValue        �<    observation_type      measured        B   LW_H                	long_name         8long-wave radiation measurement height above water level   units         meter           B   LW_FLAG                 	long_name         long-wave radiation sensor flag    comment       1 - system1, 2 - system2        B   HS                  standard_name         !surface_upward_sensible_heat_flux      	long_name         sensible heat flux     units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B   HL                  standard_name         surface_upward_latent_heat_flux    	long_name         latent heat flux   units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B   H_RAIN                  standard_name         Ftemperature_flux_due_to_rainfall_expressed_as_heat_flux_into_sea_water     	long_name          upward heat flux due to rainfall   units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B   TAU                 standard_name         $magnitude_of_surface_downward_stress   	long_name         wind stress    units         pascal     
_FillValue        �<    observation_type      
calculated          B    SST                 standard_name         sea_surface_skin_temperature   	long_name         sea skin temperature   units         celsius    
_FillValue        �<    observation_type      
calculated          B$   HEAT_NET                standard_name         upward_heat_flux_in_air    	long_name         net heat flux      units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B(   MASS_NET                standard_name         upward_mass_flux_of_air    	long_name         net mass flux      units         kilogram meter-2 second-1      
_FillValue        �<    observation_type      
calculated          B,   LW_NET                  standard_name          surface_net_upward_longwave_flux   	long_name         net long-wave radiation    units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B0   SW_NET                  standard_name         !surface_net_upward_shortwave_flux      	long_name         net short-wave radiation   units         watts meter-2      
_FillValue        �<    observation_type      
calculated          B4   WSPD10M                 standard_name         
wind_speed     	long_name         *calculated neutral wind speed at 10 meters     units         meter second-1     
_FillValue        �<    observation_type      
calculated          B8   AIRT1_5M                standard_name         air_temparature    	long_name         (calculated air temperature at 1.5 meters   units         celsius    
_FillValue        �<    observation_type      
calculated          B<   AIRT2_0M                standard_name         air_temparature    	long_name         (calculated air temperature at 2.0 meters   units         celsius    
_FillValue        �<    observation_type      
calculated          B@   RELH1_5M                standard_name         relative_humidity      	long_name         *calculated relative humidity at 1.5 meters     units         percent    
_FillValue        �<    observation_type      
calculated          BD   RELH2_0M                standard_name         relative_humidity      	long_name         *calculated relative humidity at 2.0 meters     units         percent    
_FillValue        �<    observation_type      
calculated          BH   history                   	long_name         file history information     �  3�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    @�҅I����;��CcTC�33CL�A#33@c�
 �D{ٚ@S33 �A33@W
= �B���@W
= �A�?J=q ��< @XQ� �B���@e �C��@e �=�*A\vt�< >\e�A���xb��< ?��ؓA4�4A��A��B�a�B�,�@�҇��J �;��CcTA�33C33A0  @c�
 �D{�3@S33 �A!��@W
= �B���@W
= �A1?J=q �=���@XQ� �B�33@e �C�&f@e ���E�@Y6~����>� �A���.��t@��\f����AC�A!�fA!��B���B��?@�Ҋ�I��;�pCcTC�Y�C  A(  @c�
 �D{l�@S33 �A&ff@W
= �B�ff@W
= �Ab?J=q �>���@XQ� �B�ff@e �C�� @e ��:�n������g�>k
�ACV��½��!���»|�A9�sA&:XA&z�B�<�B�K�@�ҍI����;��CcC�  B�  A33@c�
 �D{Y�@S33 �A$��@W
= �B�33@W
= �AV?J=q �?L��@XQ� �C@� @e �C�33@e ��	�v?�p1�+q>'f�A=��,��nIA�&��5�A"LhA$��A$�B�D(B�>�@�ҏ��J �;�OCcC�� B�33@���@c�
 �D{` @S33 �A$��@W
= �B���@W
= �A��?J=q �    @XQ� �B���@e �C���@e �����@���   =ï�A���=5݄A?��AA��A$�,A$��B��B���@�Ғ�I��;��Cb�B33B�  @�ff@c�
 �D{Y�@S33 �A$��@W
= �B���@W
= �A��?J=q �    @XQ� �BX  @e �C���@e ���l�@`>�   =I�A�6�(~ 5��!A#���L�@��A$�A$�'B���B���@�ҕI����;�dCb�C�@ B�33@�  @c�
 �D{L�@S33 �A#33@W
= �B�ff@W
= �A?J=q �    @XQ� �A.ff@e �C�ff@e ���P(@�AF    =���A�W��|6�@=0�$��@���A#R
A#w�B�ȒB���@�җ��J �;�dCb�C�ٚB�ff@�  @c�
 �D{@ @S33 �A   @W
= �B�  @W
= �A�;?J=q �    @XQ� �@���@e �C��f@e ��.@{0�    =��	AlTA��-5Ҷ�A�����K�@��A OA c�B�IYB�/�@�ҝI����;�dCb�C��3B���Aff@c�
 �D{33@S33 �A  @W
= �B���@W
= �A�?J=q ��< @XQ� �@���@e �C���@e �@[+%A����< >\�ApyB%���< A�����K�A>�A͙A��B��kB�<+@�ҟ��J �;��Cc�C�@ B�  A33@c�
 �D{,�@S33 �A��@W
= �B���@W
= �A�?J=q �    @XQ� �@���@e �C��@e �@�rA�u_    >3&A[�B7~�7	�1A�,��K�AȬA��A�B��KB���@�Ң�I��;��Cc�C�  B�  A   @c�
 �D{�@S33 �A33@W
= �B���@W
= �A�?J=q �    @XQ� �@���@e �C�ff@e �@�XA�1�    =�݆A<1BWS�7�A�2H��K�A@CAT�AIB��B��h@�ҥI����;��Cc�C�L�B�33A��@c�
 �Dz��@S33 �A��@W
= �B�  @W
= �A�?J=q �    @XQ� �@���@e �C�Y�@e �@��A�Z�    >�A��B��7/��B�����-A�>A�)A��B�u	B���@�ҧ��J �;��Cc�C�s3Bљ�A33@c�
 �Dz��@S33 �A��@W
= �B�33@W
= �A;d?J=q �    @XQ� �@�ff@e �C�Y�@e �AQ�B�d    >+��A5�B�My7\�TB ��?}A"�AҡA��B�ՀB�AG@�Ҫ�I��;�WCdC�33B���@���@c�
 �Dz� @S33 �Aff@W
= �B�ff@W
= �A�#?J=q �    @XQ� �@���@e �C�ٚ@e �@�ErB=~�    =��A�oB�St7���B�_��E�A	��AT]A0B�8�B�8�@�ҭI����;�WCdC��3B�33@���@c�
 �Dz��@S33 �A  @W
= �B�ff@W
= �A^5?J=q �    @XQ� �@���@e �C�&f@e �@~��B@@    =�\AhUBg�7�EjA0���K�A	�CA��A��B�>�B�<}@�ү��J �;�WCdC���B���@���@c�
 �Dz�f@S33 �Aff@W
= �B�33@W
= �A��?J=q �    @XQ� �@�ff@e �C��3@e �@�4�B4$b    =�A��B�Ry7�:A�C���?}A	�zAe�A;;B���B��@�Ҳ�I��;�WCdC�s3C 33A��@c�
 �Dz�f@S33 �A  @W
= �B�33@W
= �A�j?J=q �    @XQ� �@���@e �C�� @e �A4�NB1p>    =�؃A�)B{��7�؝AFsk��K�AA�Aw+A"bB��B��@�ҵI����;�1Cc�C�Y�Cff@�33@c�
 �Dzff@S33 �A��@W
= �B���@W
= �A�`?J=q �    @XQ� �@�  @e �C��@e �A4�B#�_    =؁�A�Ba�f7�/8A4�+��Q�ACdA��A�,B�[�B�tX@�ҷ��J �;�1Cc�@�  C
�A	��@c�
 �Dz@ @S33 �A��@W
= �B�  @W
= �A�?J=q �    @XQ� �@���@e �C��f@e �A,��B(��    >�A�Bh�k7���A$\���K�A-jA��A��B�FiB�x8@�Һ�I��;�1Cc�C�33C� A��@c�
 �Dz�@S33 �A��@W
= �B�33@W
= �A�H?J=q �    @XQ� �@ə�@e �C�  @e �A!6vB'q�    =��A��Be�L7�v^A7�e���A5�A�MA�|B��B��r@�ҽI����;�1Cc�B!33C�@陚@c�
 �Dy��@S33 �A��@W
= �B���@W
= �Aȴ?J=q �    @XQ� �B
��@e �C���@e �@� �A�ݞ    =��hA�|A���7�B���*A ��A��A��B�8�B��/@�ҿ��J �;��CcB��C%  @�  @c�
 �Dy� @S33 �Aff@W
= �B�  @W
= �AĜ?J=q �    @XQ� �B�33@e �C�ff@e �@��A�!    =�*�A���4#�7��B=����)�A?�AhUA=.B�n�B��6