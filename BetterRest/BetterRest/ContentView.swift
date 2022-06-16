//
//  ContentView.swift
//  BetterRest
//
//  Created by Johnny Huynh on 6/16/22.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmt = 8.0
    @State private var coffeeAmt = 1
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Select Time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Target Rise Time")
                }
                
                Section {
                    Stepper("\(sleepAmt.formatted()) hours", value: $sleepAmt, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired Hours of Sleep")
                }
                
                Section {
                    Stepper(coffeeAmt == 1 ? "1 cup": "\(coffeeAmt) cups", value: $coffeeAmt, in: 1...20)
                } header: {
                    Text("Cups of Coffee per Day")
                }
                
                HStack {
                    Spacer()
                    Button("Calculate", action: calcBedtime)
                    Spacer()
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Understood") {}
            } message: {
                Text(alertMsg)
            }
        }
    }
    
    func calcBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            //Hours is seconds
            let hour = (components.hour ?? 0) * 60 * 60
            //Minutes in seconds
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmt, coffee: Double(coffeeAmt))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is "
            alertMsg = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            //Error
            alertTitle = "Error"
            alertMsg = "There was a problem in the calculations."
        }
        
        showingAlert = true
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
