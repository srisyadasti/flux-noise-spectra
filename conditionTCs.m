function conditionTCs(tcMall)

% runName = tcMall(1).measProf.runName;
% runName = 'NIST1_c4';
runNames = unique({tcMall.runName});

ind = @(str) cellfun(@(x) ~isempty( strfind(x,str) ), {tcMall.filename});

%#ok<*NASGU>
for i=1:length(runNames)
   switch upper(runNames{i})
      case 'NIST1_C1'
         tcMall(ind('2010-11-17 Spectral data\SQUID1_025f_3.dat')).tcS.tMax = 29*60;
         tcMall(ind('2010-11-27 Spectral data\SQUID1_0f_1.dat')).tcS.tMin = 3*60;
         tcMall(ind('2010-11-17 Spectral data\SQUID2_025f_1.dat')).tcS.tMin = 20*60;
         tcMall(ind('2010-11-01 Spectral data\SQUID4_025f_1.dat')).tcS.tMin = 7*60;
         tcMall(ind('2010-11-01 Spectral data\SQUID4_025f_3.dat')).tcS.tMax = 28*60;
         
         % High frequency pickup:
         tcMall(ind('2010-11-01 Spectral data\SQUID6_0f_1.dat')).sf.fMax = 30;
         tcMall(ind('2010-11-01 Spectral data\SQUID5_0f_0.dat')).sf.fMax = 30;
         tcMall(ind('2010-11-02 Spectral data\SQUID5_0f_0.dat')).sf.fMax = 30;
         tcMall(ind('2010-11-01 Spectral data\SQUID2_0f_0.dat')).sf.fMax = 30;
         tcMall(ind('2010-11-02 Spectral data\SQUID2_0f_1.dat')).sf.fMax = 30;
         tcMall(ind('2010-11-01 Spectral data\SQUID1_0f_0.dat')).sf.fMax = 30;
      case 'NIST1_C4'
         tcMall(ind('2011-04-28 Spectral data 200mK\SQUID2_025f_1.')).tcS.tMin = 12*60;
         tcMall(ind('2011-04-28 Spectral data 200mK\SQUID2_025f_3.')).tcS.tMin = 19*60;
         %             tcMall(ind('2011-04-29 Spectral data 400mK\SQUID5_025f_13.')).tcS.tMin = 20*60;
         tcMall(ind('2011-05-05 Spectral data 2000mK\SQUID6_025f_1.')).tcS.tMax = 30*60;
         %             tcMall(ind('2011-04-29 Spectral data 400mK\SQUID5_025f_13.')).tcS.tMin = 25*60;
         %             tcMall(ind('2011-05-14 Spectral data 700mK\SQUID5_025f_1')).tcS.tMax = 36*60;
         %             tcMall(ind('2011-05-12 Spectral data 1500mK\SQUID1_025f_1')).sf.fMin = 1;
      case 'MIT5B3_C1'
         findobj(tcMall,'SQUID',3,'T',4,'flux',0.25,'fMax',400);
      case 'CHRIS3_C1'
         tcMall(ind('2012-01-16 Spectral data 100 mK\SQUID2_025f_2.')).tcS.tMax = 34*60;
         tcMall(ind('2012-01-16 Spectral data 100 mK\SQUID2_025f_3.')).tcS.tMax = 25*60;
         tcMall(ind('2012-01-24 Spectral data 400 mK\SQUID1_0f_1.')).tcS.tMax = 38*60;
      case 'NIST_SINX3'
         tcMall(ind('2012-04-30 100mK\SQUID4_025f_3.')).tcS.tMin = 25*60;
         tcMall(ind('2012-05-02 800mK\SQUID6_025f_5.')).tcS.tMax = 52*60;
      case 'NIST3_C1'
         tcMall(ind('\2012-07-05 100mK\SQUID1_025f_6.')).tcS.tMax = 42*60;
      case 'E543B'
         tcMall(ind('\2012-08-16 100mK\SQUID3_025f_2.')).tcS.tMax = 42*60;
      case 'E544A'
         tcMall(ind('\2012-09-07 100mK\SQUID1_025f_4.')).tcS.tMax = 325*60;
         tcMall(ind('\2012-09-10 200mK\SQUID3_025f_2.')).tcS.tMax = 10*60;
      case 'P77B'
         tcMall(ind('\2012-10-20 100mK\SQUID3_025f_1.')).tcS.tMax = 35*60;
         tcMall(ind('\2012-10-20 100mK\SQUID3_0125f_1.')).tcS.tMin = 5*60;
         tcMall(ind('\2012-10-20 100mK\SQUID3_0125f_1.')).tcS.tMax = 34*60;
         tcMall(ind('\2012-10-23 400mK\SQUID1_0f_1.')).tcS.tMin = 2*60;
      case 'SINX_BOT'
         tcMall(ind('\2013-01-15 100mK\SQUID5_025f_1.')).tcS.tMin = 35*60;
      case 'SINX_TOPBOT'
         tcMall(ind('\2013-01-20 100mK\SQUID4_025f_1.')).tcS.tMax = 46*60;
         tcMall(ind('\2013-01-22 200mK\SQUID4_025f_1.')).tcS.tMax = 44.5*60;
      case 'EPIAL_SINX'
         tcMall(ind('\2013-02-22 100mK\SQUID5_025f_1.')).tcS.tMax = 4*60;
         tcMall(ind('\2013-02-22 100mK\SQUID5_025f_4.')).tcS.tMin = 9*60;
         tcMall(ind('\2013-02-22 100mK\SQUID5_025f_4.')).tcS.tMax = 44*60;
         tcMall(ind('\2013-02-22 100mK\SQUID5_0125f_3.')).tcS.tMin = 17*60;
         tcMall(ind('\2013-02-25 200mK\SQUID5_025f_3.')).tcS.tMin = 17*60;
      case 'SGS-BD'
         tcMall(ind('\2013-04-28 400mK\SQUID2_025f_1.')).tcS.tMin = 20*60;
      case 'SGS-AC'
         tcMall(ind('\2013-05-01 100mK\SQUID3_025f_1.')).tcS.tMin = 2*60;
         tcMall(ind('\2013-05-01 100mK\SQUID1_025f_3.')).tcS.tMin = 70*60;
         tcMall(ind('\2013-05-01 100mK\SQUID1_025f_3.')).tcS.tMax = 320*60;
      otherwise
   end
end

end