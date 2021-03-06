classdef diskex < region
% DISKEX represents a region exterior to a circle.

% This file is a part of the CMToolkit.
% It is licensed under the BSD 3-clause license.
% (See LICENSE.)

% Copyright Toby Driscoll, 2014.
% Written by Everett Kropf, 2014.

properties
    extent = 2             % Default grid extent.
end

methods
    function D = diskex(center, radius)
        badargs = false;
        switch nargin
            case 0
                C = [];

            case 1
                if isa(center, 'disk') || isa(center, 'diskex')
                    C = center.outerboundary;
                elseif isa(center, 'double') && numel(center) == 3
                    C = circle(center);
                elseif isa(center, 'circle') && ~isinf(center)
                    C = center;
                else
                    badargs = true;
                end

            case 2
                if isa(center, 'double') && isa(radius, 'double') ...
                        && numel(center) == 1 && numel(radius) == 1
                    C = circle(center, radius);
                else
                    badargs = true;
                end

            otherwise
                badargs = true;
        end
        if badargs
            error('CMT:InvalidArgument', ...
                'Expected 3 points or a center and radius.')
        end

        if isempty(C)
            supargs = {};
        else
            supargs = {C, 'exteriorto'};
        end
        
        D = D@region(supargs{:});
        get(D, gridset);
    end
    
    function gd = carlesonGrid(D, opts)
        gd = carlesonGrid(disk(0, 1), opts);
        
        c = center(inner(D));
        r = radius(inner(D));
        gd = c + r/gd;
    end
    
    function gd = grid(D, varargin)
        opts = get(D);
        opts = set(opts, varargin{:});
        
        switch opts.gridType
            case 'polar'
                gd = polarGrid(D, opts);
                
            case 'carleson'
                gd = carlesonGrid(D, opts);
                
            otherwise
                error('CMT:NotDefined', ...
                    'Grid type "%s" not recognized.', type)
        end
    end
    
    function tf = hasgrid(~)
        tf = true;
    end

    function gd = polarGrid(D, opts)
        nrad = opts.numRadialLines;
        ncirc = opts.numCircularLines;

        npt = 200;
        c = center(inner(D));
        r = radius(inner(D));

        % Grid extent radius extension.
        re = D.extent*r - r;

        curves = cell(nrad + ncirc, 1);
        zg = re*(1:npt)'/(npt+1);
        for k = 1:nrad
            curves{k} = c + exp(2i*pi*(k-1)/nrad)*(r + zg);
        end
        zg = exp(2i*pi*(0:npt-1)'/(npt-1));
        for k = 1:ncirc
            curves{nrad + k} = c + (r + re*k/(ncirc + 1))*zg;
        end

        gd = gridcurves(curves);
    end
end

end
