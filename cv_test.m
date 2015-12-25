function conf = cv_test(conf, key, val)
try
  eval(['conf.' key ';']);
catch
  eval(['conf.' key ' = val;']);
end