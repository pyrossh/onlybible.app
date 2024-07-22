package dev.pyrossh.onlyBible

import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute

@Composable
fun AppHost(model: AppViewModel) {
    val navController = rememberNavController()
    val verses by model.verses.collectAsState()
    val navigateToChapter = { props: ChapterScreenProps ->
        model.resetScrollState()
        navController.navigate(props)
    }
    val onSwipeLeft = {
        val pair = model.getForwardPair()
        navigateToChapter(
            ChapterScreenProps(
                bookIndex = pair.first,
                chapterIndex = pair.second,
            )
        )
    }
    val onSwipeRight = {
        val pair = model.getBackwardPair()
        if (navController.previousBackStackEntry != null) {
            val previousBook =
                navController.previousBackStackEntry?.arguments?.getInt("bookIndex")
                    ?: 0
            val previousChapter =
                navController.previousBackStackEntry?.arguments?.getInt("chapterIndex")
                    ?: 0
//          println("currentBackStackEntry ${previousBook} ${previousChapter} || ${pair.first} ${pair.second}")
            if (previousBook == pair.first && previousChapter == pair.second) {
                println("Popped")
                navController.popBackStack()
            } else {
                println("navigated with stack")
                navController.navigate(
                    ChapterScreenProps(
                        bookIndex = pair.first,
                        chapterIndex = pair.second,
                        dir = Dir.Right.name,
                    )
                )
            }
        } else {
            println("navigated without stack")
            navController.navigate(
                ChapterScreenProps(
                    bookIndex = pair.first,
                    chapterIndex = pair.second,
                    dir = Dir.Right.name
                )
            )
        }
    }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .let {
                if (model.isLoading) it.alpha(0.5f) else it
            }
    ) {
        if (verses.isNotEmpty()) {
            AppDrawer(model = model, navigateToChapter = navigateToChapter) { openDrawer ->
                NavHost(
                    navController = navController,
                    startDestination = ChapterScreenProps(model.bookIndex, model.chapterIndex)
                ) {
                    composable<ChapterScreenProps>(
                        enterTransition = {
                            val props = this.targetState.toRoute<ChapterScreenProps>()
                            slideIntoContainer(
                                Dir.valueOf(props.dir).slideDirection(),
                                tween(400),
                            )
                        },
                        exitTransition = {
                            val props = this.targetState.toRoute<ChapterScreenProps>()
                            slideOutOfContainer(
                                Dir.valueOf(props.dir).slideDirection(),
                                tween(400),
                            )
                        },
                        popEnterTransition = {
                            slideIntoContainer(
                                AnimatedContentTransitionScope.SlideDirection.Right,
                                tween(400),
                            )
                        },
                        popExitTransition = {
                            slideOutOfContainer(
                                AnimatedContentTransitionScope.SlideDirection.Right,
                                tween(400),
                            )
                        }
                    ) {
                        val props = it.toRoute<ChapterScreenProps>()
                        SideEffect {
                            model.bookIndex = props.bookIndex
                            model.chapterIndex = props.chapterIndex
                        }
                        ChapterScreen(
                            model = model,
                            onSwipeLeft = onSwipeLeft,
                            onSwipeRight = onSwipeRight,
                            bookIndex = props.bookIndex,
                            chapterIndex = props.chapterIndex,
                            openDrawer = openDrawer,
                        )
                    }
                }
            }
        }
        if (model.isLoading) {
            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator()
            }
        }
    }
}