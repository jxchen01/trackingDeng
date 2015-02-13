function Options=set_parameters(sq)

Options=struct();
Options.Wstr=4; 
Options.Wrepel=2;
Options.alpha=0.1;
Options.beta=0;
Options.gamma=1;
Options.w0=6;

Options.nPoints=25;
Options.lengthCanSkip=15;
Options.shrinkRate=0.3;

Options.Iteration=10;

Options.Verbose=true;

if(sq==1)
    Options.bIdx=1;
    Options.rIdx=3;
    Options.numFrame=75;
    Options.gn=5;
elseif(sq==5)
    Options.bIdx=1;
    Options.rIdx=3;
    Options.numFrame=73;
    Options.gn=11;
elseif(sq==8)
    Options.bIdx=3;
    Options.rIdx=2;
    Options.numFrame=51;
    Options.gn=5;
elseif(sq==11)
    Options.bIdx=[];
    Options.rIdx=[];
    Options.numFrame=400;
    Options.gn=5;
elseif(sq==21) 
    Options.bIdx=3;
    Options.rIdx=2;
    Options.numFrame=360;
    Options.gn=17;
elseif(sq==22)
    Options.bIdx=2;
    Options.rIdx=1;
    Options.numFrame=360;
    Options.gn=23;
elseif(sq==23)
    Options.bIdx=1;
    Options.rIdx=3;
    Options.numFrame=360;
    Options.gn=17;
elseif(sq==24)
    Options.bIdx=1;
    Options.rIdx=2;
    Options.numFrame=360;
    Options.gn=17;
else
    Options.bIdx=[];
    Options.rIdx=[];
    Options.numFrame=0;
end


