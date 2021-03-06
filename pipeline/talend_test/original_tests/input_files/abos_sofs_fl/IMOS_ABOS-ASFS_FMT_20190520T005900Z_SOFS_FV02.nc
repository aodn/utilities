CDF      
      TIME       h_string   �   h_num            .   project       "Integrated Marine Observing System     conventions       IMOS version 1.3   title         =Heat and radiative flux data from Southern Ocean Flux Station      institution        Australian Bureau of Meteorology   date_created      2019-05-21T00:25:03Z   abstract             comment       �COARE Bulk Flux Algorithm version 3.0b (Fairall et 
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
Trajectory     geospatial_lat_min                -46.85800      geospatial_lat_max                -46.85610      geospatial_lon_min                142.35001      geospatial_lon_max                142.35699      geospatial_vertical_min       0.0    geospatial_vertical_max       0.0    time_coverage_start       2019-05-20T00:59:00Z   time_coverage_end         2019-05-20T23:59:00Z   data_centre       'eMII eMarine Information Infrastructure    data_center_email         info@emii.org.au   author_email      janice.sisson@bom.gov.au   author        Janice Sisson      principal_investigator        Eric Schulz    citation      �Citation to be used in publications should follow 
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
calculated          BH   history                   	long_name         file history information     �  3�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    @ؿB�I��;m�CY�B333C.�3A	��@c�
 �D|�3@S33 �AP  @W
= �B�ff@W
= �AM�P?J=q �?��@XQ� �B�33@e �C�L�@e ��.�@"a
;�Xq>��AMr�s��2LA�,A��APR7APe�B��?B�ym@ؿG��J �;m]CY�BJ  C3�fA33@c�
 �D|y�@S33 �AQ��@W
= �B���@W
= �AMC�?J=q ��< @XQ� �B���@e �C��f@e ����v@��m�< =��wAM,�³.��< @������7AV}AQ�4AQ�B���B��D@ؿJ�I��;mCCY�Bn��C2�fA��@c�
 �D|9�@S33 �AP  @W
= �B���@W
= �AK��?J=q �    @XQ� �B�  @e �C�ٚ@e ����!@��I    >��AK�¯A�6,�@�:���ǮA AP1TAPP{B�޵B��~@ؿMI����;m]CY�B33C5�A33@c�
 �D{��@S33 �AP  @W
= �B�ff@W
= �AK�?J=q �    @XQ� �B���@e �C���@e ���>�@�j�    >>QAK���n6!i1A��{dA+[�AP6�APTB���B���@ؿW��J �;m]CZ^A)��CffA��@c�
 �D{�3@S33 �AL��@W
= �B�ff@W
= �AN�D?J=q ��< @XQ� �@�ff@e �C�@ @e �?ZRA��< =���AN[9@�Ѭ�< @D���^5A��AMghAM`�B��,B���@ؿZ�I��;m]CZ^C��fC
�@�ff@c�
 �D{��@S33 �AK33@W
= �B���@W
= �ANv�?J=q �    @XQ� �@�33@e �C�� @e �?��AH��    =��PAN�A���6�d�A���XA�$AK�wAK�(B�9B� �@ؿ]I����;m]CZ^A^ffC�@ٙ�@c�
 �D{��@S33 �AK33@W
= �B���@W
= �ANA�?J=q �    @XQ� �@���@e �C���@e �?� A4�    =�v�AMS�B:�W6��B	���-@��yAK�dAK��B�sKB�8�@ؿ_��J �;mCC[#@���CL�@�ff@c�
 �D{s3@S33 �AH  @W
= �B�33@W
= �AL�D?J=q �    @XQ� �@�  @e �C��3@e �@�:AgU�    =�v?AK�B8�86��B	%���33@뗮AH��AH�tB��B��F@ؿb�I��;mCC[#C�ٚCL�@�ff@c�
 �D{Y�@S33 �AH  @W
= �B�33@W
= �AL��?J=q �    @XQ� �@�ff@e �C�L�@e �@+�Ao�G    =��AL"B�%6��A�)���?}@뤬AH�AH�bB��B��=@ؿeI����;mCC[#C��Cff@���@c�
 �D{9�@S33 �AI��@W
= �B�33@W
= �AK�m?J=q �    @XQ� �@���@e �C��3@e �?�A��    =ŹDAJ�XBnQX7,�B����-A9(AJ.�AJ*PB��=B�0@ؿmI����;l�C[#C���B�ffA	��@c�
 �Dz��@S33 �A>ff@W
= �B���@W
= �AFȴ?J=q ��< @XQ� �@���@e �C��@e �@ʌ�A�Z��< >��AF�BL��< A�����K�A��A?l�A??�B�'�B���@ؿo��J �;l�C[#C��3C� Aff@c�
 �Dz�3@S33 �A>ff@W
= �B�33@W
= �AFj?J=q �    @XQ� �@���@e �C�Y�@e �@��B�3    >�7AE�]BI�7e):Ayyc��K�Af5A?f?A?;�B�ʫB�:E@ؿr�I��;l�C[#C�@ B�  A#33@c�
 �Dz�3@S33 �A9��@W
= �B�33@W
= �AJ��?J=q �    @XQ� �@���@e �C�L�@e �A�KB:7^    >]tAJ0ZB�lr7�5�A3���dZA5'wA;6�A:�JB��B�Q�@ؿw��J �;mC[#C�  B�A.ff@c�
 �Dz�3@S33 �AC33@W
= �B���@W
= �AGƨ?J=q ��< @XQ� �@�33@e �C��f@e �@y��B%���< >��AG$DBeո�< A�s���XAA�6AC��AC�7B��5B�z\@ؿz�I��;mC[#C���B�33A.ff@c�
 �Dz��@S33 �AC33@W
= �B���@W
= �ADff?J=q �    @XQ� �@�ff@e �C��@e �>Zm�B��    >�?AC�B(�D7|�^AO���^5AAn�AC�LAC�,B�
)B��W@ؿ}I����;mC[#Ad��B���A<��@c�
 �Dz��@S33 �AD��@W
= �B���@W
= �ADE�?J=q �    @XQ� �A�33@e �C�L�@e ����nB�o    >���AC�[A�D�7�r�A3������AQ�	AE<AED�B���B�U�@ؿ��J �;n�C[d>���B�  A<��@c�
 �Dz��@S33 �AH  @W
= �B�  @W
= �ACƨ?J=q �    @XQ� �Bdff@e �C�@ @e �����B�*    >��ACf��LR7t:?A3��WևAQ��AH3rAHQ�B�~B��P