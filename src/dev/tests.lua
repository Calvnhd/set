-- Test Suite - Automated tests for rogue mode functionality
local ConfigValidator = require('services.ConfigValidator')
local GameModeModel = require('models.GameModeModel')
local RoundManager = require('services.RoundManager')
local ProgressManager = require('services.ProgressManager')
local GameModel = require('models.GameModel')
local RulesService = require('services.RulesService')
local DeckModel = require('models.DeckModel')

local Tests = {}

-- Test results tracking
local testResults = {
    passed = 0,
    failed = 0,
    tests = {}
}

-- Test assertion helper
local function assert_equal(actual, expected, message)
    if actual == expected then
        return true
    else
        error(message .. " - Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual))
    end
end

local function assert_true(condition, message)
    if condition then
        return true
    else
        error(message .. " - Expected true, got false")
    end
end

local function assert_false(condition, message)
    if not condition then
        return true
    else
        error(message .. " - Expected false, got true")
    end
end

-- Run a single test
local function runTest(testName, testFunction)
    print("Running test: " .. testName)

    local success, errorMessage = pcall(testFunction)

    if success then
        testResults.passed = testResults.passed + 1
        testResults.tests[testName] = {
            status = "PASSED"
        }
        print("  ✓ " .. testName .. " PASSED")
    else
        testResults.failed = testResults.failed + 1
        testResults.tests[testName] = {
            status = "FAILED",
            error = errorMessage
        }
        print("  ✗ " .. testName .. " FAILED: " .. errorMessage)
    end
end

-- Test configuration validator
function Tests.testConfigValidator()
    runTest("Config Validator - Valid Configuration", function()
        local validConfig = {
            id = "test_round",
            name = "Test Round",
            attributes = {
                number = {1, 2},
                color = {"red", "green"},
                shape = {"diamond"},
                fill = {"empty", "solid"}
            },
            setSize = 3, -- Changed from 2 to 3
            boardSize = {
                columns = 3,
                rows = 3
            }, -- Increased board size
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 5
            }
        }

        local bValid, message = ConfigValidator.validateRoundConfig(validConfig)
        assert_true(bValid, "Valid configuration should pass validation")
    end)

    runTest("Config Validator - Invalid Set Size", function()
        local invalidConfig = {
            id = "test_round",
            name = "Test Round",
            attributes = {
                number = {1},
                color = {"red"},
                shape = {"diamond"},
                fill = {"empty"}
            },
            setSize = 2, -- Invalid set size (too small)
            boardSize = {
                columns = 3,
                rows = 3
            },
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 5
            }
        }

        local bValid, message = ConfigValidator.validateRoundConfig(invalidConfig)
        assert_false(bValid, "Invalid set size should fail validation")
        assert_true(string.find(message, "Set size must be"), "Should mention set size requirement")
    end)

    runTest("Config Validator - Invalid Attribute Values", function()
        local invalidConfig = {
            id = "test_round",
            name = "Test Round",
            attributes = {
                number = {1, 2},
                color = {"purple"}, -- Invalid color
                shape = {"diamond"},
                fill = {"empty"}
            },
            setSize = 3, -- Valid set size
            boardSize = {
                columns = 3,
                rows = 3
            },
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 5
            }
        }

        local bValid, message = ConfigValidator.validateRoundConfig(invalidConfig)
        assert_false(bValid, "Invalid attribute values should fail validation")
    end)
end

-- Test game mode model
function Tests.testGameModeModel()
    runTest("Game Mode Model - Mode Switching", function()
        GameModeModel.initialize()

        local GAME_MODES = GameModeModel.getGameModes()

        -- Test initial state
        assert_equal(GameModeModel.getCurrentMode(), GAME_MODES.CLASSIC, "Should start in classic mode")
        assert_true(GameModeModel.isClassicMode(), "Should be in classic mode")
        assert_false(GameModeModel.isRogueMode(), "Should not be in rogue mode")

        -- Test switching to rogue mode
        GameModeModel.setMode(GAME_MODES.ROGUE)
        assert_equal(GameModeModel.getCurrentMode(), GAME_MODES.ROGUE, "Should switch to rogue mode")
        assert_false(GameModeModel.isClassicMode(), "Should not be in classic mode")
        assert_true(GameModeModel.isRogueMode(), "Should be in rogue mode")

        -- Test round index
        assert_equal(GameModeModel.getCurrentRoundIndex(), 1, "Should start at round 1")
        GameModeModel.setCurrentRoundIndex(3)
        assert_equal(GameModeModel.getCurrentRoundIndex(), 3, "Should update round index")
    end)
end

-- Test round manager
function Tests.testRoundManager()
    runTest("Round Manager - Round Progression", function()
        RoundManager.initialize()

        local totalRounds = RoundManager.getTotalRounds()
        assert_true(totalRounds > 0, "Should have rounds defined")

        -- Test starting a round
        local config = RoundManager.startRound(1)
        assert_true(config ~= nil, "Should return configuration for round 1")
        assert_equal(config.id, "tutorial_1", "Should start with tutorial_1") -- Test round completion checking - we need to mock some conditions
        -- Since the new round completion depends on card states, we'll use test spies

        -- Mock case 1: Deck not empty, board has valid sets
        local originalDeckIsEmpty = DeckModel.isEmpty
        local originalHasValidSetOfSize = RulesService.hasValidSetOfSize
        -- Mock deck not empty and board has valid sets - round should not be complete
        DeckModel.isEmpty = function()
            return false
        end
        RulesService.hasValidSetOfSize = function()
            return true
        end
        assert_false(RoundManager.IsRoundComplete(), "Round should not be complete when valid sets exist")

        -- Mock deck empty and less than 3 cards on board - round should be complete
        DeckModel.isEmpty = function()
            return true
        end
        local originalGetBoard = GameModel.getBoard
        GameModel.getBoard = function()
            return {
                [1] = "card1",
                [2] = "card2"
            }
        end
        assert_true(RoundManager.IsRoundComplete(), "Round should be complete when deck empty and < 3 cards on board")

        -- Mock deck empty but board has valid sets - round should not be complete
        GameModel.getBoard = function()
            return {
                [1] = "card1",
                [2] = "card2",
                [3] = "card3"
            }
        end
        RulesService.hasValidSetOfSize = function()
            return true
        end
        assert_false(RoundManager.IsRoundComplete(),
            "Round should not be complete when valid sets exist even with empty deck")

        -- Mock deck empty and no valid sets - round should be complete
        RulesService.hasValidSetOfSize = function()
            return false
        end
        assert_true(RoundManager.IsRoundComplete(), "Round should be complete when no valid sets can be formed")

        -- Restore original functions
        DeckModel.isEmpty = originalDeckIsEmpty
        RulesService.hasValidSetOfSize = originalHasValidSetOfSize
        GameModel.getBoard = originalGetBoard

        -- Test advancement
        assert_true(RoundManager.gameHasMoreRounds(), "Should have more rounds available")
    end)
end

-- Test variable set size rules
function Tests.testVariableSetSizes()
    runTest("Rules Service - 3-Card Sets", function()
        -- Create a simple deck for testing
        DeckModel.create()
        local deck = DeckModel.getDeck()

        -- Take first 9 cards and test 3-card set validation
        local testCards = {}
        for i = 1, 9 do
            testCards[i] = deck[i]
        end
        local testBoard = testCards

        -- Test that the system can find 3-card sets
        local validSet = RulesService.findValidSetOfSize(testBoard, 3)
        -- Note: This test would need predefined card combinations to be meaningful
        -- but it verifies the function doesn't crash with 3-card sets
    end)

    runTest("Rules Service - 4-Card Sets", function()
        -- Test for 4-card sets
        DeckModel.create()
        local deck = DeckModel.getDeck()

        local testBoard = {}
        for i = 1, 12 do
            testBoard[i] = deck[i]
        end

        local validSet = RulesService.findValidSetOfSize(testBoard, 4)
        -- Note: This test would need predefined card combinations to be meaningful
    end)

    runTest("Rules Service - Invalid 2-Card Sets", function()
        -- Test that 2-card sets are rejected
        DeckModel.create()
        local deck = DeckModel.getDeck()

        local testBoard = {deck[1], deck[2], deck[3], deck[4]}

        -- Should return nil for 2-card sets (not supported)
        local validSet = RulesService.findValidSetOfSize(testBoard, 2)
        assert_nil(validSet, "2-card sets should not be supported")

        -- Should return false for 2-card validation
        local bIsValid = RulesService.isValidSetOfSize({deck[1], deck[2]}, 2)
        assert_false(bIsValid, "2-card sets should be invalid")
    end)
end

-- Test dynamic board sizing
function Tests.testDynamicBoarding()
    runTest("Game Model - Dynamic Board Size", function()
        GameModel.reset()

        -- Test default size
        local cols, rows = GameModel.getBoardDimensions()
        local size = GameModel.getBoardSize()
        assert_equal(size, cols * rows, "Board size should match dimensions")

        -- Test reconfiguration
        GameModel.configureBoardSize(3, 2)
        local newCols, newRows = GameModel.getBoardDimensions()
        local newSize = GameModel.getBoardSize()

        assert_equal(newCols, 3, "Should update columns")
        assert_equal(newRows, 2, "Should update rows")
        assert_equal(newSize, 6, "Should update total size")
    end)
end

-- Test progress management
function Tests.testProgressManager()
    runTest("Progress Manager - Save/Load", function()
        ProgressManager.initialize()

        -- Clear any existing progress
        ProgressManager.resetProgress()

        -- Test initial state
        assert_false(ProgressManager.hasSavedProgress(), "Should not have saved progress initially")

        -- Set up some game state
        GameModeModel.setMode(GameModeModel.getGameModes().ROGUE)
        GameModeModel.setCurrentRoundIndex(2)
        GameModel.setScore(10)
        GameModel.setSetsFound(3)

        -- Save progress
        local saveSuccess = ProgressManager.saveProgress()
        assert_true(saveSuccess, "Should save progress successfully")
        assert_true(ProgressManager.hasSavedProgress(), "Should have saved progress")

        -- Reset state
        GameModeModel.setCurrentRoundIndex(1)
        GameModel.setScore(0)
        GameModel.setSetsFound(0)

        -- Load progress
        local loadSuccess = ProgressManager.loadProgress()
        assert_true(loadSuccess, "Should load progress successfully")

        -- Apply to game state
        ProgressManager.applyProgressToGame()

        -- Verify loaded state
        assert_equal(GameModeModel.getCurrentRoundIndex(), 2, "Should restore round index")
        assert_equal(GameModel.getScore(), 10, "Should restore score")
        assert_equal(GameModel.getSetsFound(), 3, "Should restore sets found")
    end)
end

-- Test deck generation from attributes
function Tests.testDeckGeneration()
    runTest("Deck Model - Attribute-Based Generation", function()
        local testConfig = {
            attributes = {
                number = {1, 2},
                color = {"red", "green"},
                shape = {"diamond"},
                fill = {"empty", "solid"}
            }
        }

        DeckModel.createFromConfig(testConfig)
        local deck = DeckModel.getDeck()

        -- Should create 2 * 2 * 1 * 2 = 8 cards
        assert_equal(#deck, 8, "Should generate correct number of cards")

        -- Verify all cards have only specified attributes
        for _, cardRef in ipairs(deck) do
            local card = cardRef:getCard()
            assert_true(card.number == 1 or card.number == 2, "Card should have valid number")
            assert_true(card.color == "red" or card.color == "green", "Card should have valid color")
            assert_equal(card.shape, "diamond", "Card should have valid shape")
            assert_true(card.fill == "empty" or card.fill == "solid", "Card should have valid fill")
        end
    end)
end

-- Run all tests
function Tests.runAll()
    print("Starting Rogue Mode Test Suite")
    print("===============================")

    testResults = {
        passed = 0,
        failed = 0,
        tests = {}
    }

    Tests.testConfigValidator()
    Tests.testGameModeModel()
    Tests.testRoundManager()
    Tests.testVariableSetSizes()
    Tests.testDynamicBoarding()
    Tests.testProgressManager()
    Tests.testDeckGeneration()

    print("\n===============================")
    print("Test Results:")
    print("  Passed: " .. testResults.passed)
    print("  Failed: " .. testResults.failed)
    print("  Total:  " .. (testResults.passed + testResults.failed))

    if testResults.failed > 0 then
        print("\nFailed Tests:")
        for testName, result in pairs(testResults.tests) do
            if result.status == "FAILED" then
                print("  - " .. testName .. ": " .. result.error)
            end
        end
    end

    print("===============================")

    return testResults.failed == 0
end

-- Get test results
function Tests.getResults()
    return testResults
end

return Tests
