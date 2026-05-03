import SharedDesignSystem
import SwiftUI

public struct ReflectionView: View {
    @State private var viewModel: ReflectionViewModel

    public init(viewModel: ReflectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        List {
            generatedSection
            actionSection
            savedSection
        }
        .navigationTitle("Reflection")
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .task {
            viewModel.loadSavedReflections()
        }
    }

    private var generatedSection: some View {
        Section("Today") {
            if viewModel.isGenerating {
                HStack(spacing: AppSpacing.sm) {
                    ProgressView()
                    Text("Generating reflection")
                        .foregroundStyle(.secondary)
                }
            } else if let reflection = viewModel.generatedReflection {
                Text(reflection.text)
                    .font(.title3.weight(.medium))
                    .padding(.vertical, AppSpacing.sm)
            } else {
                Text("Generate a mindful reflection when you are ready.")
                    .foregroundStyle(.secondary)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.generateReflection()
                }
            } label: {
                Label("Generate", systemImage: "sparkles")
            }
            .disabled(viewModel.isGenerating)

            Button {
                viewModel.saveCurrentReflection()
            } label: {
                Label("Save", systemImage: "tray.and.arrow.down")
            }
            .disabled(viewModel.generatedReflection == nil || viewModel.isSaving)
        }
    }

    private var savedSection: some View {
        Section("Saved") {
            if viewModel.savedReflections.isEmpty {
                Text("Saved reflections appear here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.savedReflections) { reflection in
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(reflection.text)
                            .font(.body)
                        Text(reflection.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, AppSpacing.xs)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteSavedReflection(reflection)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReflectionView(
            viewModel: ReflectionViewModel(
                generateReflectionUseCase: PreviewGenerateReflectionUseCase(),
                saveReflectionUseCase: PreviewSaveReflectionUseCase(),
                fetchSavedReflectionsUseCase: PreviewFetchSavedReflectionsUseCase(),
                deleteSavedReflectionUseCase: PreviewDeleteSavedReflectionUseCase()
            )
        )
    }
}

private struct PreviewGenerateReflectionUseCase: GenerateReflectionUseCase {
    func execute(locale: String, tone: String) async throws -> Reflection {
        Reflection(
            text: "Like a compass returning north, let your next small choice return to what matters.",
            model: "preview"
        )
    }
}

private struct PreviewSaveReflectionUseCase: SaveReflectionUseCase {
    @MainActor
    func execute(_ reflection: Reflection) throws {}
}

private struct PreviewFetchSavedReflectionsUseCase: FetchSavedReflectionsUseCase {
    @MainActor
    func execute() throws -> [Reflection] {
        [
            Reflection(
                text: "Let your next step be simple and kind.",
                model: "preview"
            )
        ]
    }
}

private struct PreviewDeleteSavedReflectionUseCase: DeleteSavedReflectionUseCase {
    @MainActor
    func execute(id: UUID) throws {}
}
