model classroom_simulation

// Part 6 – Step 5: Create the Environment
global {

    int nb_students <- 25;
    float world_size <- 100.0;
    bool is_break <- false;

    // monitoring variables
    float avg_energy -> { student mean_of each.energy };
    float avg_score -> { student mean_of each.score };
    int low_energy_count -> { student count (each.energy <= 0) };

    init {
        create student number: 20; //create student number: 20;
    }

    reflex classroom_cycle {
        if (cycle mod 30 = 0) {
            is_break <- !is_break;
        }
        save [cycle, avg_energy, avg_score, is_break, low_energy_count]
        to: "classroom_data.csv"
        format: "csv"
        rewrite: (cycle = 0) ? true : false
        header: true;
    }
}

// Part 3 – Step 2: Define the Student Agent
species student {

    int energy <- 5;
    int score <- 0;
    string status <- "active";

    float mobility <- rnd(1.0);
    rgb color <- #blue;

    // Part 4 – Step 3: Add Behavior (Participation)
    reflex participate when: status = "active" {
        if flip(0.4) {
            score <- score + 1;
            energy <- energy - 1;
        }
    }

    // Part 5 – Step 4: Add Reflex for Status Update
    reflex update_status {
        if (energy <= 0) {
            status <- "inactive";
        }
    }

    reflex update_color {
        if (status = "inactive") {
            color <- #red;
        } else if (energy > 3) {
            color <- #green;
        } else {
            color <- #yellow;
        }
    }

    reflex move {
        float step_size <- mobility * 2;
        float angle <- rnd(360.0);
        location <- location + {step_size * cos(angle), step_size * sin(angle)};
    }

    aspect base {
        draw circle(2) color: color;
    }
}

experiment classroom_simulation type: gui {

    parameter "Initial number of students:" var: nb_students min: 10 max: 100;

    output {
        display main_display type: 2d {
            species student aspect: base;
        }
        monitor "Average Energy" value: avg_energy;
        monitor "Average Score" value: avg_score;
        monitor "Low Energy Count" value: low_energy_count;
    }
}