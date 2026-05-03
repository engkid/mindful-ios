import SharedDesignSystem
import SwiftUI

public struct BreathingTutorialView: View {
	@State private var phase: BreathingPhase = .inhale
	@State private var circleScale = BreathingPhase.shrunkScale
	
	public init() {}
	
	public var body: some View {
		ScrollView {
			VStack(spacing: AppSpacing.xl) {
				breathingVisual
				instructionCard
				phaseList
			}
			.padding(AppSpacing.lg)
			.frame(maxWidth: .infinity)
		}
		.background(AppColor.background)
		.navigationTitle("Breathing")
		.task {
			await runCycle()
		}
	}
	
	private var breathingVisual: some View {
		ZStack {
			Circle()
				.stroke(AppColor.secondaryBackground, lineWidth: 28)
				.frame(width: 260, height: 260)
			
			Circle()
				.fill(Color.blue.opacity(0.16))
				.frame(width: 178, height: 178)
				.scaleEffect(circleScale)
			
			Circle()
				.stroke(Color.blue, lineWidth: 4)
				.frame(width: 178, height: 178)
				.scaleEffect(circleScale)
			
			VStack(spacing: AppSpacing.xs) {
				Text(phase.title)
					.font(.title.weight(.semibold))
				Text("\(phase.duration) sec")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.transaction { transaction in
				transaction.animation = nil
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.top, AppSpacing.lg)
	}
	
	private var instructionCard: some View {
		VStack(alignment: .leading, spacing: AppSpacing.sm) {
			Text(phase.instruction)
				.font(.headline)
			Text("Follow the circle. Expand as you inhale, stay steady on hold, shrink as you exhale.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(AppSpacing.md)
		.background(AppColor.secondaryBackground)
		.clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
	}
	
	private var phaseList: some View {
		VStack(alignment: .leading, spacing: AppSpacing.sm) {
			Text("Cycle")
				.font(.headline)
			
			ForEach(BreathingPhase.allCases, id: \.self) { item in
				HStack {
					Image(systemName: item == phase ? "circle.fill" : "circle")
						.foregroundStyle(item == phase ? Color.blue : Color.secondary)
					Text(item.title)
					Spacer()
					Text("\(item.duration)s")
						.foregroundStyle(.secondary)
				}
				.font(.subheadline)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	private func runCycle() async {
		while !Task.isCancelled {
			for nextPhase in BreathingPhase.allCases {
				await MainActor.run {
					phase = nextPhase
					
					withAnimation(.easeInOut(duration: Double(nextPhase.duration))) {
						circleScale = nextPhase.scale
					}
				}
				
				do {
					try await Task.sleep(for: .seconds(nextPhase.duration))
				} catch {
					return
				}
			}
		}
	}
}

private enum BreathingPhase: CaseIterable, Hashable {
	case inhale
	case hold
	case exhale
	case rest
	
	static let shrunkScale: CGFloat = 0.82
	
	var title: String {
		switch self {
		case .inhale:
			"Inhale"
		case .hold:
			"Hold"
		case .exhale:
			"Exhale"
		case .rest:
			"Rest"
		}
	}
	
	var instruction: String {
		switch self {
		case .inhale:
			"Breathe in slowly through your nose."
		case .hold:
			"Keep your breath soft and steady."
		case .exhale:
			"Release the breath through your mouth."
		case .rest:
			"Let your body settle before the next round."
		}
	}
	
	var duration: Int {
		switch self {
		case .inhale:
			4
		case .hold:
			4
		case .exhale:
			6
		case .rest:
			2
		}
	}
	
	var scale: CGFloat {
		switch self {
		case .inhale:
			1.34
		case .hold:
			1.34
		case .exhale:
			Self.shrunkScale
		case .rest:
			Self.shrunkScale
		}
	}
}

#Preview {
	NavigationStack {
		BreathingTutorialView()
	}
}
