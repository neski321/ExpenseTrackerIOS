//
//  ContentView.swift
//  PennyPincherIOS
//
//  Created by Neskines Otieno on 2025-07-03.
//

import SwiftUI
import Combine

struct ContentView: View {
    enum Screen: String, CaseIterable, Identifiable {
        case dashboard, expenses, search, income, categories, incomeSources, paymentMethods, settings
        var id: String { rawValue }
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .expenses: return "Expenses"
            case .search: return "Search"
            case .income: return "Income"
            case .categories: return "Categories"
            case .incomeSources: return "Income Sources"
            case .paymentMethods: return "Payment Methods"
            case .settings: return "Settings"
            }
        }
        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .expenses: return "dollarsign.circle"
            case .search: return "magnifyingglass"
            case .income: return "chart.line.uptrend.xyaxis"
            case .categories: return "tag"
            case .incomeSources: return "banknote"
            case .paymentMethods: return "creditcard"
            case .settings: return "gear"
            }
        }
    }
    
    @State private var selectedScreen: Screen = .dashboard
    @StateObject private var authService = AuthService()
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    
    var body: some View {
        if authService.user == nil {
            AuthFlowView(authService: authService)
        } else {
            TabView(selection: $selectedScreen) {
                DashboardScreen(userId: authService.userId ?? "", selectedTab: $selectedScreen)
                    .tabItem {
                        Label(Screen.dashboard.title, systemImage: Screen.dashboard.icon)
                    }
                    .tag(Screen.dashboard)
                ExpensesScreen(userId: authService.userId ?? "")
                    .tabItem {
                        Label(Screen.expenses.title, systemImage: Screen.expenses.icon)
                    }
                    .tag(Screen.expenses)
                SearchExpensesScreen()
                    .tabItem {
                        Label(Screen.search.title, systemImage: Screen.search.icon)
                    }
                    .tag(Screen.search)
                IncomeScreen(userId: authService.userId ?? "")
                    .tabItem {
                        Label(Screen.income.title, systemImage: Screen.income.icon)
                    }
                    .tag(Screen.income)
                CategoriesScreen(userId: authService.userId ?? "")
                    .tabItem {
                        Label(Screen.categories.title, systemImage: Screen.categories.icon)
                    }
                    .tag(Screen.categories)
                IncomeSourcesScreen(userId: authService.userId ?? "")
                    .tabItem {
                        Label(Screen.incomeSources.title, systemImage: Screen.incomeSources.icon)
                    }
                    .tag(Screen.incomeSources)
                PaymentMethodsScreen(userId: authService.userId ?? "")
                    .tabItem {
                        Label(Screen.paymentMethods.title, systemImage: Screen.paymentMethods.icon)
                    }
                    .tag(Screen.paymentMethods)
                SettingsScreen(colorScheme: $colorScheme, authService: authService)
                    .tabItem {
                        Label(Screen.settings.title, systemImage: Screen.settings.icon)
                    }
                    .tag(Screen.settings)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authService.signOut()
                    }
                }
            }
            .preferredColorScheme(colorScheme == "dark" ? .dark : colorScheme == "light" ? .light : nil)
        }
    }
}

struct AuthFlowView: View {
    @ObservedObject var authService: AuthService
    @State private var currentScreen: AuthScreen = .welcome
    enum AuthScreen {
        case welcome, login, signup
    }
    var body: some View {
        switch currentScreen {
        case .welcome:
            WelcomeScreen(onGetStarted: {
                currentScreen = .login
            })
        case .login:
            LoginScreen(
                onLoginSuccess: {
                    // Use AuthService for login
                },
                onNavigateToSignup: {
                    currentScreen = .signup
                },
                authService: authService
            )
        case .signup:
            SignupScreen(
                onSignupSuccess: {
                    currentScreen = .login
                },
                onNavigateToLogin: {
                    currentScreen = .login
                },
                authService: authService
            )
        }
    }
}

#Preview {
    ContentView()
}
