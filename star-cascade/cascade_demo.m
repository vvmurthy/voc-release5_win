function cascade_demo()

% Run cascade demo.
% 
% Note that unless you have compiled fconv.cpp as your convolution
% function, you will be comparing a multi-threaded version of the
% DP algorithm to a single-threaded version of the cascade algorithm.

%load('C:\Users\Veda\Documents\MATLAB\voc-release5\VOC2010\car_final');
%test('000034.jpg', model);
%fprintf('\nPress any key to continue with demo'); pause; fprintf('...ok\n\n');


%INRIAPERSON uses 2007 data *called* 2010 data to work- due to the fact
%INRIA is 1-time use database
load('INRIA/inriaperson_final'); 

%strcat for file name
img = 'control.jpg';
fileloc = 'C:\Users\Veda\Documents\MATLAB\voc-release5\partiallyoccluded\';
filename = strcat(fileloc,img);

test(filename, model);
fprintf('\nPress any key to continue with demo'); pause; fprintf('...ok\n\n');

%load('VOC2007/bicycle_final');
%test('000084.jpg', model);


function test(impath, model)

name = model.class;

clf;
fprintf('///// Running demo for %s /////\n\n', name);

fprintf('Loading a test image');
fprintf('...done\n');

im = imread(impath);
subplot(1,3,1);
imagesc(im);
axis image;
axis off;

fprintf('Compute cascade thresholds');
fprintf('...done\n');

%thresh changed to -0.3 for better INRIA detections
%thresh = -0.5;
thresh = -0.3;

pca = 5;
orig_model = model;
%csc_model = cascade_model(model, '2007', pca, thresh);
csc_model = cascade_model(model, '2010', pca, thresh);
orig_model.thresh = csc_model.thresh;

fprintf('Building the feature pyramid...');

th = tic();
pyra = featpyramid(double(im), csc_model);
tF = toc(th);

fprintf('done\n');
fprintf('  --> Feature pyramid generation took %f seconds\n', tF);
fprintf('Computing detections with dynamic programming...');

th = tic;
[dDP, bDP] = gdetect(pyra, orig_model, orig_model.thresh);
tDP = toc(th);
fprintf('done\n');
fprintf('  --> DP detection took %f seconds\n', tDP);

fprintf('Computing detections with star-cascade...');

th = tic;
[dCSC, bCSC] = cascade_detect(pyra, csc_model, csc_model.thresh);
tCSC = toc(th);

fprintf('done\n');
fprintf('  --> Cascade detection took %f seconds\n', tCSC);
fprintf('  --> Speedup = %fx\n', tDP/tCSC);

b = getboxes(orig_model, im, dDP, reduceboxes(orig_model, bDP));
subplot(1,3,2);
showboxes(im, b);
title('dynamic programming detections');

b = getboxes(csc_model, im, dCSC, bCSC);
subplot(1,3,3);
showboxes(im, b);
title('star-cascade detections');


function b = getboxes(model, image, det, all)
b = [];
if ~isempty(det)
  try
    % attempt to use bounding box prediction, if available
    bboxpred = model.bboxpred;
    [det all] = clipboxes(image, det, all);
    [det all] = bboxpred_get(bboxpred, det, all);
  catch
    warning('no bounding box predictor found');
  end
  [det all] = clipboxes(image, det, all);
  I = nms(det, 0.5);
  det = det(I,:);
  all = all(I,:);
  b = [det(:,1:4) all];
end
