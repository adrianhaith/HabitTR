% quantify # of responses during critical habit window

for c=1:3
    for subject=1:24
        if(~isempty(data(subject,c).RT))
            Nwindow(c,subject) = sum(data(subject,c).RT>.3 & data(subject,c).RT<.6)
            %Nwindow_switch(c,subject) = sum(data(subject,c).RT>.3 & data(subject,c).RT<.6 & )
        else
            Nwindow(c,subject) = NaN;
        end
    end
end