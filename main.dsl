import "commonReactions/all.dsl";

context
{  
    input phone: string;
    output new_time: string="";
    output new_day: string="";
    output number_of_people: string="";
    output flight_stars: string="";
    output board_in_date: string="";
    output board_in_month: string="";
    output city: string="";
    output state: string="";
    output free: string="";  
    output return_date: string="";
    output return_month: string="";

    date: string="";
    month: string="";
    number_value: string="";
}


start node root
{
    do
    {
        #connectSafe($phone);
        #waitForSpeech(1000);
        #sayText("Hi, my name is Dasha, I'm here to assist you with finding and booking a flight. First, could you tell me which city and state you're traveling to, please?"); // Welcome message
        wait *;
    }
    transitions 
    {
        flight_stars: goto flight_stars on #messageHasData("city") and #messageHasData("state"); 
        which_city: goto which_city on #messageHasData("state"); 
        which_state: goto which_state on #messageHasData("city");
    }
     onexit
    {
        flight_stars: do {
        set $city = #messageGetData("city")[0]?.value??""; // Store city and state variables to use them later in the conversation
        set $state = #messageGetData("state")[0]?.value??"";
        }
        which_city: do {
        set $state = #messageGetData("state")[0]?.value??"";
        }
        which_state: do {
        set $city = #messageGetData("city")[0]?.value??"";
        }
    }
}

node which_city
{
    do
    {
        #sayText("And which city in " + $state + " are you going to?"); // $state comes from context 
        wait *;
    }
    transitions
    {
        flight_stars: goto flight_stars on #messageHasData("city");
    }
    onexit
    {
        flight_stars: do {
        set $city = #messageGetData("city")[0]?.value??"";
        }
    }
}

node which_state
{
    do
    {
        #sayText("Sorry, could you specify the state for me, please?");
        wait *;
    }
    transitions
    {
        flight_stars: goto flight_stars on #messageHasData("state");
    }
    onexit
    {
        flight_stars: do {
        set $state = #messageGetData("state")[0]?.value??"";
        }
    }
}

node flight_stars
{
    do
    {
        #sayText("That's nice! " + $city + " is a beautiful place! Ummm... Whats the review you want the flight to have?");
        wait *;
    }
    transitions
    {
        how_many_people: goto how_many_people on #messageHasData("number_value", {tag: "stars"}) or #messageHasData("number_value");
    }
    onexit
    {
        how_many_people: do {
        set $flight_stars = #messageGetData("number_value", {tag: "stars"})[0]?.value??"";
        }
    }
}


node how_many_people
{
    do
    {
        #sayText("Fantastic, I got that! " + $flight_stars + " it is! Now, could you tell me how many people you said are flying with you?");
        wait *;
    }
    transitions
    {
        confirm_guests: goto confirm_guests on #messageHasData("number_value", {tag: "people"}) or #messageHasData("number_value"); 
    }
    onexit
    {
        confirm_guests: do {
        set $number_of_people = #messageGetData("number_value", {tag: "people"})[0]?.value??"";
        }
    }
}

node confirm_guests
{
    do 
    { 
        #sayText("You said " + $number_of_people + ", is that right?");
        wait *;
    }
    transitions
    {
        board_in_date: goto board_in_date on #messageHasIntent("yes");
        repeat_guests: goto repeat_guests on #messageHasIntent("no");
    }
}

node repeat_guests
{
    do 
    {
        #sayText("Let's do it one more time. How many people you said are accompanying you?");
        wait *;
    }
    transitions 
    {
       confirm_guests: goto confirm_guests on #messageHasData("number_value", {tag: "date"});
    }
    onexit
    {
        confirm_guests: do {
        set $number_of_people = #messageGetData("number_value", {tag: "people"})[0]?.value??"";
        }
    }
}

node board_in_date
{
    do
    {
        #sayText("Just a couple more questions so I could ensure I pick the best flight for you so please bear with me. Could you give me the date you had to like to board in?");
        wait *;
    }
    transitions 
    {
       confirm_board_in: goto confirm_board_in on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_board_in: do {
        set $board_in_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $board_in_month  = #messageGetData("month")[0]?.value??"";
        }
    }
}


node confirm_board_in
{
    do 
    { 
        #sayText("Alrighty, I'm setting the date to " + $board_in_month + " " + $board_in_date + " , did I get that right?");
        wait *;
    }
    transitions
    {
        return_date: goto return_date on #messageHasIntent("yes");
        repeat_board_in: goto repeat_board_in on #messageHasIntent("no");
    }
}

node repeat_board_in
{
    do 
    {
        #sayText("Let's try again. When would you like to board in to your flight?");
        wait *;
    }
    transitions 
    {
       board_in: goto board_in_date on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
       board_in: do {
        set $board_in_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $board_in_month = #messageGetData("month")[0]?.value??"";
        }
    }
}

node return_date
{
    do
    {
        #sayText("Now, could you tell me when the return date should be?");
        wait *;
    }
    transitions 
    {
       confirm_return: goto confirm_return on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_return: do {
        set $return_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $return_month  = #messageGetData("month")[0]?.value??"";
        }
    }
}


node confirm_return
{
    do 
    { 
        #sayText("Awesome, so just to make sure, the return date is " + $return_month + " " + $return_date + " , am I rigth?");
        wait *;
    }
    transitions 
    {
        free: goto free on #messageHasIntent("yes");
        repeat_return: goto repeat_return on #messageHasIntent("no");
    }
    onexit
    {
       free: do {
       set $free = #messageGetData("free")[0]?.value??""; 
       }
    }
}

node repeat_return
{
    do 
    {
        #sayText("Let's do this again. When should I set the return date to?");
        wait *;
    }
    transitions 
    {
       confirm_return: goto confirm_return on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_return: do {
        set $return_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $return_month = #messageGetData("month")[0]?.value??"";
        }
    }
}

node free
{
    do 
    {   
        #sayText(" is fascinating! Now, would you require a drink or free Wi-Fi to be present at the in the plane");
        wait *;
    }
    transitions 
    {
       free_confirm: goto free_confirm on #messageHasData("free");
    }
    onexit
    {
       free_confirm: do {
       set $free = #messageGetData("free")[0]?.value??""; 
       }
    }
}

node free_confirm
{
    do 
    {   
        if ($free == "free wifi"){
            #sayText("Sounds like a plan, I'll look for a flight that has free wifi. Let's figure out the pricing you're comfortable with. Would you like the flight to be economy, business or first class?");
        }
        else if ($free == "free wifi and food"){
            #sayText("Sounds like a plan, I'll look for a flight that has both free food and wifi. Let's figure out the pricing you're comfortable with. Would you like the flight to be economy, business or first class?");
        }
        else {
            #sayText("Sounds like a plan, I'll look for a flight that has free Wi-Fi. Let's figure out the pricing you're comfortable with. Would you like the flight to be economy, business or first class?");
        }
        wait *;
    }
    transitions 
    {
        economy_flight: goto economy on #messageHasIntent("economy_flight");
        business_class: goto business on #messageHasIntent("business_class");
        first_class: goto first_class on #messageHasIntent("first_class");
        cost_doesnt_matter: goto cost_doesnt_matter on #messageHasIntent("cost_doesnt_matter");
    }
}

node economy
{
    do 
    {
        #sayText("To review your requirements, you want to find a economy seat to " + $city + " , the number of tickets " + $number_of_people + ", the reviews should be " + $flight_stars + " stars, the board date would be " + $board_in_month + " " + $board_in_date + ", and the return date would be" + $return_month + " " + $return_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_economy: goto search_economy on #messageHasIntent("yes");
    }
}

node first_class
{
    do 
    {
        #sayText("To review your requirements, you want to find a first class flight in " + $city + " , the seating would be for " + $number_of_people + ", the flight will have " + $flight_stars + " stars, the check-in date would be " + $board_in_month + " " + $board_in_date + ", and the return date would be" + $return_month + " " + $return_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_first_clas: goto search_first_clas on #messageHasIntent("yes");
    }
}

node business
{
    do 
    {
        #sayText("To review your requirements, you want to find a business flight in " + $city + " , the seating would be for " + $number_of_people + ", the flight will have " + $flight_stars + " stars, the check-in date would be " + $board_in_month + " " + $board_in_date + ", and the return date would be" + $return_month + " " + $return_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_medium_price: goto search_business on #messageHasIntent("yes");
    }
}

node cost_doesnt_matter
{
    do 
    {
        #sayText("To review your requirements, you want to find a high price range flight in " + $city + " , the seating would be for " + $number_of_people + ", the flight will have " + $flight_stars + " stars, the check-in date would be " + $board_in_month + " " + $board_in_date + ", and the return date would be" + $return_month + " " + $return_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_flight: goto search_flight on #messageHasIntent("yes");
    }
}

node search_economy
{
    do 
    {
        #sayText("Awesome, I found two flights that perfectly match your requirements. The first one is Franklin and the second one is Garfield. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        Franklin: goto Franklin on #messageHasIntent("Franklin");
        garfield: goto garfield on #messageHasIntent("garfield");
    }
}

node Franklin
{
    do 
    {
        #sayText("The seat costs 400 dollars per person. Would you like to book this one or hear more about the garfield airlines?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        garfield: goto garfield on #messageHasIntent("garfield");
    }
}

node garfield
{
    do 
    {
        #sayText("This flight costs 450 dollars per person and it serves free food. Would you like to book this one or hear more about the Franklin Airliner?");
        wait *;
    }
    transitions 
    {
        Franklin: goto Franklin on #messageHasIntent("Franklin");
        book: goto book on #messageHasIntent("book");
    }
}

node search_business
{
    do 
    {
        #sayText("Awesome, I found two flights that perfectly match your requirements. The first one is Hello flight and the second one is Sunflower. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        velvet: goto velvet on #messageHasIntent("velvet");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
    }
}

node velvet
{
    do 
    {
        #sayText("This flight costs 880 dollars per person. It provides free continental breakfasts. Would you like to book this one or hear more about the Sunflower Airways?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
    }
}

node sunflower
{
    do 
    {
        #sayText("This flight costs 900 dollars per person and it serves free food and has free wifi. Would you like to book this one or hear more about the Hello flight?");
        wait *;
    }
    transitions 
    {
        velvet: goto velvet on #messageHasIntent("velvet");
        book: goto book on #messageHasIntent("book");
    }
}

node search_first_clas
{
    do 
    {
        #sayText("Awesome, I found two flights that perfectly match your requirements. The first one is Dandelion flight and the second one is Rose Petal Inn. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        rose: goto rose on #messageHasIntent("rose");
    }
}

node dandelion
{
    do 
    {
        #sayText("This flight costs 1217 dollars per person. It provides free continental breakfasts, has flexible check out time, and a free outside and inside pools. Would you like to book this one or hear more about the Rose Petal Inn?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        rose: goto rose on #messageHasIntent("rose");
    }
}

node rose
{
    do 
    {
        #sayText("This flight costs 1311 dollars per person and it serves free food of various cusines, it comes with a personal suite. Would you like to book this one or hear more about the Dandelion flight?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        book: goto book on #messageHasIntent("book");
    }
}

node search_flight
{
    do 
    {
        #sayText("Awesome, I found four flights that perfectly match your requirements. The first one is Dandelion flight, the second is Rose airways, the third one is Sunflower airways and the last one is garfield. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        rose: goto rose on #messageHasIntent("rose");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
        garfield: goto garfield on #messageHasIntent("garfield");
    }
}

node book
{
    do 
    {
        #sayText("Perfect, the seats for the flight has been booked! It was a pleasure helping you find the right flight. I'll send the booking confirmation and other information in a text message. Have a fantastic rest of the day. Bye!");
        exit;
    }
}