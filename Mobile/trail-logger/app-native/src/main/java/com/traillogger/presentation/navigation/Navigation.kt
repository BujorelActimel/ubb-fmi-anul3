package com.traillogger.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.traillogger.presentation.detail.TrailDetailScreen
import com.traillogger.presentation.login.LoginScreen
import com.traillogger.presentation.trails.TrailListScreen

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object TrailList : Screen("trail_list")
    object TrailDetail : Screen("trail_detail/{trailId}") {
        fun createRoute(trailId: Int) = "trail_detail/$trailId"
    }
}

@Composable
fun NavigationGraph(
    navController: NavHostController,
    startDestination: String
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigate(Screen.TrailList.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.TrailList.route) {
            TrailListScreen(
                onTrailClick = { trailId ->
                    navController.navigate(Screen.TrailDetail.createRoute(trailId))
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.TrailList.route) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Screen.TrailDetail.route,
            arguments = listOf(
                navArgument("trailId") {
                    type = NavType.IntType
                }
            )
        ) {
            TrailDetailScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
