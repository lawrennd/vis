HOME = getenv('HOME');

addpath([HOME '/mlprojects/bayesianMicroarrayImage/matlab']);
addpath([HOME '/mlprojects/matlab/netlab']);
addpath([HOME '/mlprojects/matlab/general']);
addpath([HOME '/mlprojects/matlab/drawing']);


CURRENTIMAGE = imread('demoimage.tif');

imageData = max(CURRENTIMAGE, [], 3);
image(CURRENTIMAGE);

axis equal
axis off

set(gca, 'xlim', [0 200])
set(gca, 'ylim', [70 170])

txtTitle = title('Variational Importance Sampling: Demo 2');
set(txtTitle, 'fontsize', 24);
set(txtTitle, 'fontname', 'verdana');
horizLine = line([1 200], [95 95; 122 122; 150 150]);
vertLine = line([29 29; 54 54; 79 79; 104 104; 129 129; 154 154; 179 ...
		179], [1 200]);

color = get(horizLine(1), 'color');
set(horizLine, 'linewidth', 1, 'linestyle', '--', 'color', color);
set(vertLine, 'linewidth', 1, 'linestyle', '--', 'color', color);
lowerBackground = 6500;
upperBackground = 10000;
dustSpotPoint = 65035;
numSamps = 200;

centrePrior.beta = .2; % The precision of the centres prior
centrePrior.S_inv = eye(2); % The covariance of the centre's wishart distribution
centrePrior.nu = 4;% The degrees of freedom of the centre's wishart distribution
radiusPrior.mu = [10 10];  % The mean of the radii prior
radiusPrior.beta = .2; % The precision of the radii prior 
radiusPrior.S_inv = eye(2); % The inverse covariance of the radii's wishart distribution
radiusPrior.nu  = 4;% The degrees of freedom of the centre's wishart distribution

maxWidth = 25; % THe maximum width of a spot
maxHeight = 25; % The maximum height of a spot

display = 2;
maxIters = 20;
xRange = [29:25:179];
yRange  = [95 122 150];
counter = 0;
for x = xRange
  for y = yRange
    counter = counter + 1;
    origOval(counter) = ovalcreate([x y], radiusPrior.mu(1), radiusPrior.mu(2));
    origOval(counter).selected = 0;
    origOval(counter) = ovaldraw(origOval(counter));
    set(origOval(counter).handle, 'linestyle', ':', 'color', [1 0 1])
  end
end
disp('Press any key')
pause
for x = xRange
  for y = yRange
    centrePrior.mu = [x y];  % The mean of the centres prior
[ovals, importanceWeights] = microarrayOvals(imageData, centrePrior, radiusPrior, ...
					     maxWidth, maxHeight, ...
					     lowerBackground, upperBackground, ...
					     dustSpotPoint, ...
					     numSamps, display, maxIters);
  end
end















