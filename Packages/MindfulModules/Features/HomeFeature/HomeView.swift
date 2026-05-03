import SharedDesignSystem
import SharedUIComponents
import SwiftUI

public struct HomeView: View {
	private let onShowSample: () -> Void
	private let onShowBreathingTutorial: () -> Void
	private let onShowReflection: () -> Void
	
	public init(
		onShowSample: @escaping () -> Void,
		onShowBreathingTutorial: @escaping () -> Void,
		onShowReflection: @escaping () -> Void
	) {
		self.onShowSample = onShowSample
		self.onShowBreathingTutorial = onShowBreathingTutorial
		self.onShowReflection = onShowReflection
	}
	
	public var body: some View {
		TabBarView(
			onShowSample: onShowSample,
			onShowBreathingTutorial: onShowBreathingTutorial,
			onShowReflection: onShowReflection
		)
			.navigationTitle("Mindful")
	}
}

public struct TabBarView: View {
	private let onShowSample: () -> Void
	private let onShowBreathingTutorial: () -> Void
	private let onShowReflection: () -> Void
	
	public init(
		onShowSample: @escaping () -> Void,
		onShowBreathingTutorial: @escaping () -> Void,
		onShowReflection: @escaping () -> Void
	) {
		self.onShowSample = onShowSample
		self.onShowBreathingTutorial = onShowBreathingTutorial
		self.onShowReflection = onShowReflection
	}
	
	public var body: some View {
		TabView {
			HomeTabContent(
				onShowSample: onShowSample,
				onShowBreathingTutorial: onShowBreathingTutorial,
				onShowReflection: onShowReflection
			)
				.tabItem {
					Label("home", systemImage: "house")
				}
			
			SettingsTabContent()
				.tabItem {
					Label("settings", systemImage: "gearshape")
				}
		}
	}
}

private struct HomeTabContent: View {
	private let greetingProvider = HomeGreetingProvider()
	private let onShowSample: () -> Void
	private let onShowBreathingTutorial: () -> Void
	private let onShowReflection: () -> Void
	
	init(
		onShowSample: @escaping () -> Void,
		onShowBreathingTutorial: @escaping () -> Void,
		onShowReflection: @escaping () -> Void
	) {
		self.onShowSample = onShowSample
		self.onShowBreathingTutorial = onShowBreathingTutorial
		self.onShowReflection = onShowReflection
	}
	
	var body: some View {
		List {
			Section {
				TimelineView(.periodic(from: .now, by: 60)) { context in
					VStack(alignment: .leading, spacing: AppSpacing.sm) {
						Text(greetingProvider.greeting(for: context.date))
							.font(.title2.weight(.semibold))
						Text("Take one mindful pause before the next task.")
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					.padding(.vertical, AppSpacing.sm)
				}
			}
			
			Section("Practice") {
				Button(action: onShowSample) {
					Label("Open Sample Feature", systemImage: "rectangle.stack")
				}
				
				Button(action: onShowBreathingTutorial) {
					Label("Breathing", systemImage: "wind")
				}
				Button(action: onShowReflection) {
					Label("Reflection", systemImage: "text.book.closed")
				}
			}
		}
		.scrollContentBackground(.hidden)
		.background(AppColor.background)
	}
}

private struct SettingsTabContent: View {
	@State private var remindersEnabled = true
	@State private var soundEnabled = false
	
	var body: some View {
		List {
			Section("Preferences") {
				Toggle("Reminders", isOn: $remindersEnabled)
				Toggle("Sound", isOn: $soundEnabled)
			}
			
			Section("Profile") {
				LabeledContent("Mode", value: "Guest")
				LabeledContent("Version", value: "1.0")
			}
		}
		.scrollContentBackground(.hidden)
		.background(AppColor.background)
	}
}

#Preview {
	NavigationStack {
		HomeView(
			onShowSample: {},
			onShowBreathingTutorial: {},
			onShowReflection: {}
		)
	}
}
