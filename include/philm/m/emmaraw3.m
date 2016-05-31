                %emmaraw3.m
                %more processing, emma raw voltage data
	%do decimation and/or smoothing, skip if no filter defined
            if ncof
		nsampo=floor((nsamp-1)./idown)+1;
	        for kk=1:nemmacol
	            emmadat(1:nsampo,kk)= decifir(bcof,emmadat(:,kk),idown);
	        end;
	        emmadat=emmadat(1:nsampo,:);
	        nsamp=nsampo;
            end;
