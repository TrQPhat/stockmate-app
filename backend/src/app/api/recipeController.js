const { Recipe, Recipe_ingredient, Ingredient, User, StorageMember } = require("../models");
const { v4: uuidv4 } = require('uuid');
const { Op } = require("sequelize");

class RecipeController {

    //--- QUẢN LÝ CÔNG THỨC (recipes) ---

    async getAllRecipe(req, res) {
        try {
            const recipes = await Recipe.findAll({
                include: [{ model: User, attributes: ['full_name', 'avatar_url'] }]
            });
            res.status(200).json(recipes);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy danh sách công thức." });
        }
    }

    async getRecipeById(req, res) {
        try {
            const recipe = await Recipe.findByPk(req.params.dishId, {
                include: [
                    { model: User, attributes: ['full_name', 'avatar_url'] },
                    {
                        model: Recipe_ingredient,
                        include: [{ model: Ingredient, attributes: ['name', 'image_path'] }]
                    }
                ]
            });

            if (!recipe) {
                return res.status(404).json({ error: "Công thức không tồn tại." });
            }
            res.status(200).json(recipe);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy thông tin công thức." });
        }
    }

    async createRecipe(req, res) {
        try {
            const { name, description, instructions, cook_time_minutes, serving_size, ingredients } = req.body;
            const created_by_user_id = req.user.user_id; // Lấy từ token

            // Tạo công thức trước
            const newRecipe = await Recipe.create({
                id: uuidv4(),
                name,
                description,
                instructions,
                cook_time_minutes,
                serving_size,
                created_by_user_id
            });

            // Nếu có nguyên liệu, thêm chúng vào
            if (ingredients && ingredients.length > 0) {
                const ingredientPromises = ingredients.map(ing => {
                    return Recipe_ingredient.create({
                        id: uuidv4(),
                        dish_id: newRecipe.id,
                        product_id: ing.product_id,
                        quantity: ing.quantity,
                        unit: ing.unit
                    });
                });
                await Promise.all(ingredientPromises);
            }

            res.status(201).json(newRecipe);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Lỗi khi tạo công thức." });
        }
    }

    async updateRecipe(req, res) {
        try {
            const recipe = await Recipe.findByPk(req.params.dishId);
            if (!recipe) {
                return res.status(404).json({ error: "Công thức không tồn tại." });
            }
            // Chỉ chủ sở hữu mới được cập nhật
            if (recipe.created_by_user_id !== req.user.user_id) {
                return res.status(403).json({ error: "Bạn không có quyền cập nhật công thức này." });
            }

            const { name, description, instructions, cook_time_minutes, serving_size } = req.body;
            await Recipe.update({
                name: name ?? recipe.name,
                description: description ?? recipe.description,
                instructions: instructions ?? recipe.instructions,
                cook_time_minutes: cook_time_minutes ?? recipe.cook_time_minutes,
                serving_size: serving_size ?? recipe.serving_size
            });

            res.status(200).json(recipe);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi cập nhật công thức." });
        }
    }

    async deleteRecipe(req, res) {
        try {
            const recipe = await Recipe.findByPk(req.params.dishId);
            if (!recipe) {
                return res.status(404).json({ error: "Công thức không tồn tại." });
            }
            if (recipe.created_by_user_id !== req.user.user_id) {
                return res.status(403).json({ error: "Bạn không có quyền xóa công thức này." });
            }

            await Recipe.destroy(); // Se xoa luon cac ingredients neu co onDelete: 'CASCADE'
            res.status(200).json({ message: "Xóa công thức thành công." });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa công thức." });
        }
    }

    // TÍNH NĂNG "HÔM NAY NẤU GÌ?"
    async suggestRecipe(req, res) {
        try {
            const userUUID = req.user.user_id;

            // 1. Lấy tất cả storage_id mà user có quyền truy cập
            const memberOfStorages = await StorageMember.findAll({
                where: { user_id: userUUID },
                attributes: ['storage_id']
            });
            const accessibleStorageIds = memberOfStorages.map(member => member.storage_id);

            // 2. Lấy tất cả sản phẩm "còn dùng" từ các kho đó và tổng hợp lại
            const userProducts = await Ingredient.findAll({
                where: {
                    storage_id: { [Op.in]: accessibleStorageIds },
                    status: 'con_dung',
                    quantity: { [Op.gt]: 0 } // Chỉ lấy sản phẩm có số lượng > 0
                }
            });

            // Dùng Map để tra cứu số lượng sản phẩm nhanh hơn
            const userInventory = new Map();
            userProducts.forEach(p => {
                const currentQuantity = userInventory.get(p.id) || 0;
                userInventory.set(p.id, currentQuantity + p.quantity);
            });

            // 3. Lấy tất cả công thức và nguyên liệu cần thiết
            const allRecipe = await Recipe.findAll({
                include: {
                    model: Recipe_ingredient,
                    required: true // Chỉ lấy các món có ít nhất 1 nguyên liệu
                }
            });

            // 4. Phân loại công thức
            const cookableRecipe = [];
            const nearlyCookableRecipe = [];

            allRecipe.forEach(recipe => {
                let missingIngredients = [];
                let ownedIngredientsCount = 0;

                recipe.RecipeIngredients.forEach(requiredIngredient => {
                    const availableQuantity = userInventory.get(requiredIngredient.product_id) || 0;
                    if (availableQuantity >= requiredIngredient.quantity) {
                        ownedIngredientsCount++;
                    } else {
                        missingIngredients.push({
                            product_id: requiredIngredient.product_id,
                            required_quantity: requiredIngredient.quantity,
                            available_quantity: availableQuantity
                        });
                    }
                });

                // Nếu không thiếu nguyên liệu nào -> Có thể nấu
                if (missingIngredients.length === 0) {
                    cookableRecipe.push(recipe);
                }
                // Nếu có > 60% nguyên liệu -> Gần có thể nấu
                else if ((ownedIngredientsCount / recipe.RecipeIngredients.length) > 0.6) {
                    nearlyCookableRecipe.push({
                        recipe,
                        missingIngredients
                    });
                }
            });

            res.status(200).json({
                cookableRecipe,
                nearlyCookableRecipe
            });

        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Lỗi khi xử lý gợi ý công thức." });
        }
    }

    //--- QUẢN LÝ NGUYÊN LIỆU (recipe INGREDIENTS) ---

    async addIngredient(req, res) {
        try {
            const { dishId } = req.params;
            const { product_id, quantity, unit } = req.body;

            const recipe = await Recipe.findByPk(dishId);
            if (!recipe) return res.status(404).json({ error: "Công thức không tồn tại." });
            if (recipe.created_by_user_id !== req.user.user_id) return res.status(403).json({ error: "Không có quyền." });

            const newIngredient = await Recipe_ingredient.create({
                id: uuidv4(),
                dish_id: dishId,
                product_id,
                quantity,
                unit
            });
            res.status(201).json(newIngredient);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi thêm nguyên liệu." });
        }
    }

    async updateIngredient(req, res) {
        try {
            const { dishId, ingredientId } = req.params;
            const { quantity, unit } = req.body;

            const recipe = await Recipe.findByPk(dishId);
            if (!recipe) return res.status(404).json({ error: "Công thức không tồn tại." });
            if (recipe.created_by_user_id !== req.user.user_id) return res.status(403).json({ error: "Không có quyền." });

            const ingredient = await Recipe_ingredient.findByPk(ingredientId);
            if (!ingredient) return res.status(404).json({ error: "Nguyên liệu không tồn tại." });

            await ingredient.update({ quantity: quantity ?? ingredient.quantity, unit: unit ?? ingredient.unit });
            res.status(200).json(ingredient);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi cập nhật nguyên liệu." });
        }
    }

    async removeIngredient(req, res) {
        try {
            const { dishId, ingredientId } = req.params;

            const recipe = await Recipe.findByPk(dishId);
            if (!recipe) return res.status(404).json({ error: "Công thức không tồn tại." });
            if (recipe.created_by_user_id !== req.user.user_id) return res.status(403).json({ error: "Không có quyền." });

            const ingredient = await Recipe_ingredient.findByPk(ingredientId);
            if (!ingredient) return res.status(404).json({ error: "Nguyên liệu không tồn tại." });

            await ingredient.destroy();
            res.status(200).json({ message: "Xóa nguyên liệu thành công." });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa nguyên liệu." });
        }
    }
}

module.exports = new RecipeController();