function [ds x] = demo()
startup;

%fprintf('compiling the code...');
%compile;
%fprintf('done.\n\n');


% the concatenation is for later, when I need to load in imagename to write
% it to a text file 
imagename = '2008_000023.jpg';
fullpath = 'C:\Users\Veda\Documents\MATLAB\voc-release5\VOC2010\VOCdevkit\VOC2010pics\JPEGimages\';
%fullpath = 'C:\Users\Veda\Documents\MATLAB\voc-release5\partiallyoccluded\';
imfullpath = strcat(fullpath,imagename);

%tests car model; irrelevant for now
%load('VOC2007/car_final');
%model.vis = @() visualizemodel(model, ...
%                  1:2:length(model.rules{model.start}));
%test('000034.jpg', model, -0.3);

%load('INRIA/inriaperson_final');
%model.vis = @() visualizemodel(model, ...
%                  1:2:length(model.rules{model.start}));
%test('000061.jpg', model, -0.3);


%test(imfullpath, model, -0.3, imagename);
%


load('VOC2010/person_grammar_final');
model.class = 'person grammar';
model.vis = @() visualize_person_grammar_model(model, 6);
[ds x] = test(imfullpath, model, -0.6);


%load('VOC2007/person_grammar_final');
%model.class = 'person grammar';
%model.vis = @() visualize_person_grammar_model(model, 6);
%test(imfullpath, model, -0.3, imagename);

%load('VOC2007/bicycle_final');
%model.vis = @() visualizemodel(model, ...
%                  1:2:length(model.rules{model.start}));
%test('000084.jpg', model, -0.3);

function [ds x] = test(imname, model, thresh)
cls = model.class;
fprintf('///// Running demo for %s /////\n\n', cls);

% load and display image
im = imread(imname);
clf;
image(im);
axis equal; 
axis on;
disp('input image');
disp('press any key to continue'); pause;
disp('continuing...');

% load and display model
model.vis();
disp([cls ' model visualization']);
disp('press any key to continue'); pause;
disp('continuing...');

% detect objects
[ds, bs] = imgdetect(im, model, thresh);
x = bs;
top = nms(ds, 0.5);
clf;
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
showboxes(im, reduceboxes(model, bs(top,:)));
disp('detections');
disp('press any key to continue'); pause;
disp('continuing...');

if model.type == model_types.MixStar
  % get bounding boxes
  bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
  bbox = clipboxes(im, bbox);
  top = nms(bbox, 0.5);
  clf;
  showboxes(im, bbox(top,:));
  disp('bounding boxes');
  
  % This code is designed to feed out so that I can check vs ground truth
  %disp('Detections Only');
  %reductionbbox = bbox(top,:);
  %disp(reductionbbox);
  %datawrite(reductionbbox, imagename);
  %
  
  disp('press any key to continue'); pause;

%The else section was added by me- model seemed to not know what to do next
%if not given outright command
else
    pause;
end

fprintf('\n');
