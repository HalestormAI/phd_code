function people = build_salient_point_distrib( people )

    if nargin < 1,
        people = addPeople;
    else
        
        if isstruct( people ),
            people = [ [people.head]', [people.torso]', [people.waist]', [people.arms]', [people.legs]', [people.feet]' ];
        end
        
        more = input('You already have some people, would you like more Y/N [Y]?','s');
        if strcmpi(more, 'Y') || isempty(more),
            more_people = addPeople;
            people = [people;more_people];
        end
    end

    
    function peoples = addPeople( )
        
        num_people = input('How many people? ');
        peoples = zeros( num_people, 6 );
        num = 1;
        while num <= num_people,
            fprintf('Person %d\n',num);

            head  = input('  Points on head: ');
            torso = input('  Points on torso: ');
            waist = input('  Points on waist: ');
            arms  = input('  Points on arms: ');
            legs  = input('  Points on legs: ');
            feet  = input('  Points on feet: ');
            disp(' ');

          %  person = struct('head',head,'torso',torso,'waist',waist,'arms',arms,'legs',legs,'feet',feet);
            person = [ head, torso, waist, arms, legs, feet ];
            peoples(num,:) = person;
            num = num + 1;
        end
    end
    
end