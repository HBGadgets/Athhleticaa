//
//  StepsView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

struct StepsCard: View {
    var calories: Double
    var steps: Int
    var distance: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .overlay(
                    // Inner edge shine (white glow around edges)
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white, lineWidth: 0.7)
                        .blur(radius: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 0.5
                                )
                                .blur(radius: 2)
                                .blendMode(.screen)
                        )
                )
                .overlay(
                    // Soft white reflection near top
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .blur(radius: 2)
                )
            
            HStack() {
                VStack {
                    Image(systemName: "flame")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text(String(format: "%.2f", calories).prefix(2))
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Kcal")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text("\(steps)")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Steps")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text(String(format: "%.2f", distance))
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Km")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity) // ✅ full width
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .cornerRadius(16)
        }
        
    }
}
